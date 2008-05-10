"This is a smart module for handling 'make' driven packages"

import re,sys,os,glob
from libkita import *

import make1
import urllib2

from ftplib import FTP

class Kita(make1.Kita):
  "This is kita object"
  def load_kita_file(self,kita_file_name):
    "Loads kita_info for a given kita file"
    f=open(kita_file_name).read()
    pat=re.compile(r'(.*?)=\"(.*?)\"',re.IGNORECASE)
    res=re.findall(pat,f)
    self.info={}

    #Convert a tuple into dictionary
    for i in res:
      self.info[i[0]]=i[1]
      
    # Chuck Name in
    self.info["NAME"]=get_name(kita_file_name)

    files_list=open("/var/kitaman/sources.list").read()

    pattern=re.compile("<a href=\"(.*?)\">%s-(.*?)</a>" % self.info["NAME"].replace("+","\+"))

    results=re.findall(pattern,files_list)

    if len(results) == 0 :
      # bad luck
      kita_error("Couldnt not find any sources for %s" % self.info["NAME"])


    # we need a temp list for our max_version function
    # and we need to convert tuple to dictionary so we can retrieve url for our max verstion
    # all in one nice loop

    temp_list=[]
    files_dict={}
    for i in results:
      temp_list.append(i[1])
      files_dict[i[1]]=i[0]


    max_ver=max_version(temp_list)
    
    file_path=files_dict[max_ver]
    
    # Lets set FILES now
    self.info["FILES"]=[file_path]

    #Also version
    self.info["VER"]=get_version(max_ver)

    #Also name with version
    self.info["NAME-VER"]=self.info["NAME"]+"-"+self.info["VER"]
    
    # BUILD is a speciall case
    pat=re.compile(r'BUILD=\"\"(.*?)\"\"\n',re.DOTALL | re.IGNORECASE)
    res=re.findall(pat,f)
    if res==[]:
      kita_error(self.info["NAME-VER"]+" cant patternpatch build")
    self.info["BUILD"]=res[0]

    # We want to seperate dependencies into a list
    if "DEPEND" in self.info.keys() :
      if self.info["DEPEND"]=="":
        self.info["DEPEND"]=[]
      else:
        self.info["DEPEND"]=self.info["DEPEND"].split()
    else:
      self.info["DEPEND"]=[]
