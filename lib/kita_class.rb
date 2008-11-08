# This is the base class for Kita, all classes shall inherit from this class !

require 'lib/kita_helper'
require 'lib/kitaman_helper'


class Kita
  attr_reader :info

  def ==(obj)
    self.info==obj.info
  end

  def initialize(kita_file)
    infos = IO.read(kita_file).scan(/(.*?)="(.*?)"\n/)
    @info = {}
    for info in infos
      @info[info[0]]=info[1]
    end

    @info = smart_set(@info,'NAME',File.basename(kita_file,".kita"))
    @info = smart_split(@info,"FILES")
    @info = smart_set(@info,'VER',self.get_version)
    @info = smart_split(@info,"DEPEND")
    @info["BUILD"] = IO.read(kita_file).scan(/BUILD=""(.*?)""/m)[0][0] if @info['BUILD']

  end

  def Kita.find_kita_file(package_name)
    all_files = `find kita_files -type f`.split("\n")
    for file in all_files
      if File.basename(file,".kita") == package_name
        return file
      end
    end
  end

  def get_version
    if @info['FILES']!=[]
      ver = get_version_from_file(@info['FILES'][0])
    else
      ver = "0.0"
    end
    return ver
  end

  def fill_files
    #TODO: this function needs help
    all_files = `find #{KitamanConfig.config['SRC_DIR']} -type f`.split("\n")
     for file in all_files
      if smart_basename(file) == @info['NAME']
        @info['FILES']=[file]
        return file
      end
    end
  end

  def download_files
    for file in @info["FILES"] 
      `wget -c #{file} -O #{KitamanConfig.config['SRC_DIR']}/#{File.basename(file)}`  
    end
  end

  def files_list_local
    list=[]
    for file in @info['FILES']
      list << (KitamanConfig.config['SRC_DIR']+'/'+File.basename(file))
    end
    list
  end

  def files_list_to_download
    @info['FILES']
  end

  def files_not_downloaded?
    not files_downloaded?
  end

  def files_downloaded?
    results = true
    for file in files_list_local 
      results = (results and File.exist?(file))
    end
    return results
  end


end
