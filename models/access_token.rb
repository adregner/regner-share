class AccessToken
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :hash, :type => String
  field :desc, :type => String
  field :serial, :type => String

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  belongs_to :user
  has_and_belongs_to_many :items

  def tree
    #
    # Note that this method will generate the complete tree for all items contained by this
    # access token each time it's called.  It will also trigger a AccessToken#save if the
    # current serial isn't equal to the freshly generated one.
    #

    #_serial, _tree
    ret = self.class.make_tree(self.items, {:token => self, :serial => true})
    _serial = ret[0]
    _tree = ret[1]

    if not self.serial == _serial
      self.serial = _serial
      save
    end

    return _tree
  end

  def self.make_tree(the_items, options = {:serial => true, :token => nil})
    _tree = {}
    ids = the_items.map do |item|
      _pointer = _tree
      path_parts = item.path.split('/')
      while path_parts.count > 0
        part = path_parts.delete_at(0)
        _pointer[part] = {} if _pointer[part].nil?
        _pointer = _pointer[part]
        # add some extra metadata to the final "leaf" of this tree (i.e. the filename)
        if path_parts.count == 0
          _pointer["._token"] = options[:token]
          _pointer["._id"] = item.id
        end
      end
      item.id
    end.sort

    if options[:serial]
      the_serial = Digest::MD5.hexdigest ids.join(';')
      return [the_serial, _tree]
    else
      return _tree
    end
  end

end
