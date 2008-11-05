# This is the base class for Kita, all classes shall inherit from this class !
class Kita
  attr_reader :info

  def initialize(kita_file)
    infos = IO.read(kita_file).scan(/(.*?)="(.*?)"\n/)
    @info = {}
    for info in infos
      @info[info[0]]=info[1]
    end
    @info['DEPEND'] = @info['DEPEND'].split(" ")
  end

  def Kita.find_kita_file(package_name)
    all_files = `find kita_files`.split("\n")
    for file in all_files
      if File.basename(file,".kita") == package_name
        return file
      end
    end
  end

end
