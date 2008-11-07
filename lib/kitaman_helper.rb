class Object
  def in(cmp)
    cmp.include? self
  end 
end


class KitamanConfig
  
  def KitamanConfig.config 
    infos = IO.read('etc/kitaman.conf').scan(/(.*?)="(.*?)"\n/)
    result = {}
    for info in infos
      result[info[0]]=info[1]
    end
    return result
  end

end
