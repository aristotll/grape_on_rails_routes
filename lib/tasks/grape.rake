namespace :grape do
  desc "show API routes"
  task routes: :environment do
    mapping = method_mapping

    grape_klasses = ObjectSpace.each_object(Class).select { |klass| klass < Grape::API }
    routes = grape_klasses.map{|x|x.routes rescue nil}.select{|x|x.present?}.
      uniq { |r| r.first.send(mapping[:path]) + r.first.send(mapping[:method]).to_s }

    method_width, path_width, version_width, desc_width = widths(routes, mapping)

    puts 'Prefix Verb URI Pattern   Controller#Action'
    routes.each do |api|
      method = api.first.send(mapping[:method]).to_s.rjust(method_width)
      path = api.first.send(mapping[:path]).to_s.ljust(path_width)
      # @type [String]
      version = api.first.send(mapping[:version]).to_s.ljust(version_width).chomp
      version_with_prefix=version.empty? ? '' : '/'+version
      desc = api.first.send(mapping[:description]).to_s.ljust(desc_width)
      #  Prefix Verb URI Pattern   Controller#Action
      puts "#{desc}     #{method}    #{version_with_prefix}#{path}    #{path}  "
    end
  end

  def widths(routes, mapping)
    [
      routes.map { |r| r.first.send(mapping[:method]).try(:length) }.compact.max || 0,
      routes.map { |r| r.first.send(mapping[:path]).try(:length) }.compact.max || 0,
      routes.map { |r| r.first.send(mapping[:version]).try(:length) }.compact.max || 0,
      routes.map { |r| r.first.send(mapping[:description]).try(:length) }.compact.max || 0
    ]
  end

  def method_mapping
    if Gem.loaded_specs['grape'].version.to_s >= "0.15.1"
      {
        method: 'request_method',
        path: 'path',
        version: 'version',
        description: 'description'
      }
    else
      {
        method: 'route_method',
        path: 'route_path',
        version: 'route_version',
        description: 'route_description'
      }
    end
  end
end
