module Kitaman
  module Dsl
    module Meta

      def post_install &block
        val = block.call
        @package.post_install_cmd = val
        Log.info "post_install_cmd set to #{val}"
      end

    end
  end
end
