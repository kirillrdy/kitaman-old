module Kitaman
  module Dsl
    module Make
      def source(source_uri)
        @package.sources = [source_uri]
        Log.info "adding #{source_uri} to files list"
      end

  #    def prefix(install_prefix)
  #      @package.set_prefix install_prefix
  #      Log.info "Changing install prefix to #{install_prefix}"
  #    end

      def patch patch_url
        @package.patches = [patch_url]
        Log.info "Adding Patch #{patch_url}"
      end

      def patches(patches)
        @package.patches = patches
        Log.info "Adding Patches #{patches}"
      end


      def pre_configure &block
        val = block.call
        @package.pre_configure_cmd = val
        Log.info "Preconfig set to #{val}"
      end

      def configure &block
        val = block.call
        @package.configure_cmd = val
        Log.info "configure set to #{val}"
      end

      def build &block
        val = block.call
        @package.build_cmd = val
        Log.info "build_cmd set to #{val}"
      end

      def install &block
        val = block.call
        @package.install_cmd = val
        Log.info "install_cmd set to #{val}"
      end

    end
  end
end
