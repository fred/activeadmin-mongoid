module ActiveAdmin
  module Mongoid
    module Adaptor
      class Search
        attr_reader :base, :query, :query_hash, :search_params

        def initialize(object, search_params = {})
          @base = object
          @search_params = search_params
          @query_hash = get_query_hash(search_params)
          @query = @base.where(@query_hash)
        end

        def respond_to?(method_id)
          @query.send(:respond_to?, method_id)
        end

        def method_missing(method_id, *args, &block)
          if is_query(method_id)
            @search_params[method_id.to_s]
          else
            @query.send(method_id, *args, &block)
          end
        end

        private

        def is_query(method_id)
          method_id.to_s =~ /_contains$/  ||
          method_id.to_s =~ /_eq$/        ||
          method_id.to_s =~ /_(gt|lt)/
        end

        def get_query_hash(search_params)
          searches = search_params.map do|k, v|
            mongoidify_search(k,v)
          end
          Hash[searches]
        end

        def mongoidify_search(k, v)
          if k =~ /_contains$/
            [get_attribute(k, '_contains'), Regexp.new(Regexp.escape("#{v}"), Regexp::IGNORECASE)]
          elsif k =~ /_eq$/
            [get_attribute(k, '_eq'), v]
          elsif k =~ /_gt$/
            [get_attribute(k, "_gt").to_sym.gt, v]
          elsif k =~ /_lt$/
            [get_attribute(k, "_lt").to_sym.lt, v]
          else
            [k, v]
          end
        end

        def get_attribute(k, postfix)
          k.match(/^(.*)#{postfix}$/)[1]
        end
      end
    end
  end
end
