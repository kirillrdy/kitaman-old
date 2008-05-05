"This is a default class for Kita(), all modules shall inherit from here"

import re
import sys
import os
import glob
from libkita import *

class Kita(object):
  "This is kita object"

  info={}
  "Dictionary that contains all the kita information"

  def __init__(self,file_name):
    "On object creationg we must load kita info, engine expects us to do so"
    self.load_kita_file(file_name)
 
  def remove(self):
    "Removes all the files that were installed by this package"
    # TODO: Please fix this function ,it needs love
    # first it still doesnt remove state file
    # second it doesnt care about revese state file
    # third , but thats in engine itself, u need ... damn lots of work
    f=open("/var/kitaman/state/"+self.info["NAME-VER"]).read()
    f=f.split("\n")
    # Please remember there ARE LEFT F**** OVERS FROM SPLIT
    f=f[:-1]
    f.reverse()
    for i in f:
        if i[-1:]=="/":
          print i
          os.system("rmdir /"+i)
          #os.rmdir("/"+i)
        else:
          os.system("rm /"+i)
          #os.remove("/"+i)

    os.system("rm /var/kitaman/state/"+self.info["NAME-VER"])

  def installed(self):
    "Returns wherether or not the package is installed"
    return os.path.exists("/var/kitaman/state/"+self.info["NAME-VER"])

  def record_installed(self):
    os.system("mkdir -p /var/kitaman/state")
    os.system("mkdir -p /var/kitaman/reverse")

    for i in self.info["DEPEND"]:
      i=glob.glob("/var/kitaman/state/"+i+"*")[0] 
      i=os.path.split(i)[1]

      f=""
      if os.path.exists("/var/kitaman/reverse/%s" % i):
        f=open("/var/kitaman/reverse/%s" % i).read()
      f=f+self.info["NAME-VER"]+"\n"
      f2=open("/var/kitaman/reverse/%s" % i,"w")
      f2.write(f)
      f2.close()

    os.system("tar -tf "+kita_config["PKG_DIR"]+"/%s-bin.tar.bz2 > /var/kitaman/state/%s" % (self.info["NAME-VER"],self.info["NAME-VER"]))
    print self.info["NAME-VER"]+" was recorded in installed list"


  def load_kita_file(self,kita_file_name):
    "Loads kita_info for a given kita file"
    f=open(kita_file_name).read()

    pat=re.compile(r'(.*?)=\"(.*?)\"', re.IGNORECASE)
    res=re.findall(pat,f)
    self.info={}

    #Convert a tuple into dictionary
    for i in res:
      self.info[i[0]]=i[1]

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
      print self.info["NAME-VER"],"Cant patternmatch BUILD"
      sys.exit(1)
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
    else:
      self.info["FILES"]=[]
 
  def downloaded(self):
    "Returns True if all files for current package are downloaded"
    if not self.info.has_key("FILES"):
      return True
    result=True
    for i in self.info["FILES"]:
      base=os.path.basename(i)
      if not os.path.exists(kita_config["SRC_DIR"]+"/"+base):
        result=False
    return result

  def download(self):
    "donwloads all missing files"
    if self.info.has_key("FILES"):
      for i in self.info["FILES"]:
          os.chdir(kita_config["SRC_DIR"])
          if os.system("wget -c %s" % i)>0:
            kita_error("Failed Fetching %s" % i)
          os.chdir("..")
    return True
