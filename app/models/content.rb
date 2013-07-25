class Content
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :filename, :slug, :extensions, :title, :body, :summary, :updated_at

  # Class methods

  def self.all
    @all ||= begin
      # TODO: use tap
      all = []
      Dir[File.join(Rails.root, "content", self.name.pluralize.underscore, "[^\*]*")].each do |f|
        all << self.parse(f)
      end
      all.sort { |a, b| a.sort_value <=> b.sort_value }
    end
  end

  def self.last
    @last ||= begin
      self.all.last
    end
  end
  
  def self.find(slug)
    # TODO: use cache instead of parsing again
    filename = self.filename_from_slug(slug)
    return if filename.nil?

    parse(filename)
  end

  def self.parse(filename)
    data, body, extensions = read_file(filename)
    klass = data["published_at"].blank? ? Page : Post
    klass.new(filename, data, body, extensions)
  end

  def self.read_file(filename)
    basename = File.basename(filename)
    published_at = basename.scan(/([^_]+)_/).flatten.first
    extensions = basename.split(".")[1..-1].reverse
    f = File.read(filename)

    if f =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      body = $' # Get the regex $POSTMATCH

      begin
        data = YAML.load($1)
      rescue => e
        puts "YAML Exception reading #{name}: #{e.message}"
      end
    end
    data ||= {}
    # TODO: move published_at in Post implementation of read_file
    data["published_at"] = published_at unless published_at.blank?
    [ data, body, extensions ]
  end

  def self.filename_from_slug(slug)
    Dir[File.join(Rails.root, "content", "**", "*#{slug}.*")].first
  end

  def self.slug_from_filename(filename)
    File.basename(filename).split(".").first
  end

  # Init

  def initialize(filename, data, body, extensions)
    self.filename = filename
    data.each do |k, v|
      self.send("#{k}=", v)
    end
    self.body = body
    self.extensions = extensions
  end

  # Accessors

  def filename=(f)
    @filename = f
    self.slug = self.class.slug_from_filename(f)
  end

  def layout
    @layout ||= "application"
  end

  def path
    slug
  end

  def to_param
    path
  end

  def persisted?
    false
  end

  def sort_value
    path
  end

end