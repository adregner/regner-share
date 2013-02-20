RegnerShare.controllers :view do

  before do
    @item_path = if request.env["HTTP_X_REQUEST_URI"]
      request.env["HTTP_X_REQUEST_URI"]
    else
      request.path_info
    end
    @item_path = URI.decode_www_form_component(@item_path).split('/')[2..-1]
  end

  get :access, :with => :hash do
    @token = AccessToken.find_by hash: params[:hash]
    return [401, "This isn't your access token."] if @token.user.id != current_account.id
    @items = @token.items
    render 'view/items'
  end

  get :tree, :map => '/view*', :priority => :low do
    begin
      found = explore_requested_tree(@item_path)
    rescue NoMethodError
      return [404, "that path doesn't exist"]
    end

    if found[0].class == Item
      @item = found[0]
    else
      @items = found[0]

      # sort them with "directories" on top
      @items = @items.sort_by {|k, v| prefix = v["._id"] ? "10_" : "00_"; prefix + k }

      # slice out the "page" we want
      start = params[:start].to_i || 0
      num_items = 20
      @prev_item = [0, (start - num_items)].max
      @next_item = (start + num_items) > @items.count ? start : (start + num_items)
      @items = @items[start...(start + num_items)]

      # convert back to a hash
      @items = @items.inject({}) { |r, s| r.merge! ({s[0] => s[1]}) }
    end

    @rm_prefix = found[1]
    if request.xhr?
      render 'view/items', :layout => false
    else
      render 'view/items'
    end
  end

  get :auth_check do
    begin
      @item = explore_requested_tree(@item_path)[0]
    rescue NoMethodError
      return [404, "that path doesn't exist"]
    end
    return "ok"
  end

  get :download, :map => "/dl/*", :priority => :low do
    begin
      @item = explore_requested_tree(@item_path)[0]
    rescue NoMethodError
      return [404, "that path doesn't exist"]
    end

    if request.env["REQUEST_METHOD"] == "HEAD" and
        request.env["REQUEST_PATH"].split('/')[-1] != @item.path
      return 200
    end

    unless File::exists? @item.path
      return [404, "that file doesn't exist"]
    end

    type = MimeMagic.by_path @item.path
    mtime = File::mtime @item.path

    send_file @item.path,
      :type => type.to_s,
      :last_modified => mtime.httpdate,
      :disposition => 'inline'
  end

end
