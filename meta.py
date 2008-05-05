import re
import sys
import os
from libkita import *
import classkita

class Kita(classkita.Kita):
  "This is kita object"

  def record_installed(self):
    os.system("mkdir -p /var/kitaman/state")
    os.system("touch /var/kitaman/state/%s" % (self.info["NAME-VER"]))
    print self.info["NAME-VER"]+" was recorded in installed list"

  def build(self):
    "executes already created shell script"
    # Because its a meta package, it doesnt need any build instructions
    return True


  def install(self):
    "For a given package name installes files from archive"
    print "Merging %s into /" % self.info["NAME-VER"]
    #os.system("tar -xjpf /kitaman/pkg/%s.tar.bz2 -C /" % name)
    #Now we run post install for this package
    os.system("mkdir -p /tmp/kitaman/%s" % self.info["NAME-VER"])
    f=open("/tmp/kitaman/%s/install-script.sh" % self.info["NAME-VER"],"w")
    std_func="""
    set -e
    NAME=%s
    PKG_DIR=%s
    mkdir -p /tmp/kitaman/${NAME}
    post_install()
    {
      echo "Post install is absent from kitafile - Doing nothing..."
    }
    """ % (self.info["NAME-VER"],kita_config["PKG_DIR"])
    f.write(std_func)
    f.write("""
pkg_install() 
{ 
tar -xjpf ${PKG_DIR}/%s-bin.tar.bz2 -C /  
}
""" % self.info["NAME-VER"])

    f.write(self.info["BUILD"]+"\n")
    #f.write("rm -rf /tmp/kitaman/*")
    f.write("post_install\n")
    f.close()

    if os.system("/bin/sh /tmp/kitaman/%s/install-script.sh" % self.info["NAME-VER"]) > 0:
      return False

    return True


  def load_kita_file(self,kita_file_name):
    "Loads kita_info for a given kita file"
    f=open(kita_file_name).read()

    pat=re.compile(r'(.*?)=\"(.*?)\"', re.IGNORECASE)
    res=re.findall(pat,f)
    self.info={}

    #Convert a tuple into dictionary
    for i in res:
      self.info[i[0]]=i[1]

    #Before Doing anything we need to find if we have the right module
    # Also in the future, the Engine should decide which kita file to load
    # and using what module
    #TODO: Make engin handling loading modules and kita files

    # Chuck Name in
    self.info["NAME"]=get_name(kita_file_name)

    #Also version
    self.info["VER"]=get_version(kita_file_name[:-5])

    #Also name with version
    self.info["NAME-VER"]=self.info["NAME"]+"-"+self.info["VER"]
    
    # BUILD is a speciall case
    pat=re.compile(r'BUILD=\"\"(.*?)\"\"\n',re.DOTALL | re.IGNORECASE)
    res=re.findall(pat,f)
    if res==[]:
      print "WARNING maybe BUILD is not matched %s, assuming blank" % self.info["NAME-VER"]
      self.info["BUILD"]=""
    else:
      self.info["BUILD"]=res[0]

    # We want to seperate dependencies into a list
    if "DEPEND" in self.info.keys() :
      if self.info["DEPEND"]=="":
        self.info["DEPEND"]=[]
      else:
        self.info["DEPEND"]=self.info["DEPEND"].split()
    else:
      self.info["DEPEND"]=[]
    #Split files into a list
    if "FILES" in self.info.keys():
      self.info["FILES"]=self.info["FILES"].split()
 
  def downloaded(self):
    return True

  def download(self):
    "Checks for needed files for package, and donwloads all missing files"
    if self.info.has_key("FILES"):
      for i in self.info["FILES"]:
        base=os.path.basename(i)
        if not os.path.exists(kita_config["SRC_DIR"]+"/"+ base):
          os.chdir(kita_config["SRC_DIR"])
          print "> Fetching %s" % i 
          os.popen("wget %s" % i)
          os.chdir("..")
    
    return True
