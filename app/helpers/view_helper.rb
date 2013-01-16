# Helper methods defined here can be accessed in any controller or view in the application

RegnerShare.helpers do

  def explore_requested_tree(path) # raises NoMethodError
    begin
      if ['jpg', 'tiff', 'bmp', 'gif', 'png', 'jpeg'].include? path[-1].downcase.split('.')[-1]
        path[-1].sub! /_([0-9]{1,4}x|x[0-9]{1,4}|[0-9]{1,4}x[0-9]{1,4}){1,2}(-[nesw]{1,2})?(\.[A-Za-z0-9]{1,5})$/,
          "\\3"
      end
    rescue
      nil
    end

    if current_account.role == "admin"
      # Admin users can see everything, reguardless
      tree = AccessToken.make_tree(Item.all, :serial => false)
    else
      # only allow users to see the items in their given tokens
      tree = {}
      current_account.access_tokens.each do |token|
        tree = merge_trees(tree, token.tree)
      end
    end

    removed_parts = []
    while tree.keys.count == 1
      removed_parts << tree.keys[0]
      tree = tree.values[0]
    end
    rm_prefix = removed_parts.join('/')

    while path.count > 0
      # allow this to potentially raise a NoMethodError to the caller
      tree = tree[path.delete_at(0)]
    end

    # add in some extra data when its just a single leaf item
    if tree["._id"]
      item = Item.find(tree["._id"])
      return [item, rm_prefix]
    else
      return [tree, rm_prefix]
    end
  end

  def download_url(item, rm_prefix, args = nil)
    item = Item.find item if item.class != Item
    args = args ? "_#{args}\\1" : "\\1"
    url(:view, :download) +
      item.path.slice(rm_prefix.length..-1).sub(/(\..+)$/, args).slice(1..-1)
  end

  def merge_trees(tree1, tree2)
    tree2.each_pair do |key, value|
      if tree1[key].nil?
        tree1[key] = value
      else
        tree1[key] = merge_trees tree1[key], value
      end
    end
    return tree1
  end

  def is_image? name
    return name.match /\.(jpg|jpeg|bmp|gif|png|tiff)$/i
  end

end
