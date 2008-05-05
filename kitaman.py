#!/usr/bin/python
""" 
    This is Kitaman - Pariah Package Manager
    "A promise to a little girl and a big world"
    Right now kitaman is pariah internal project, 
    it only means its not ready yet for world dominance,
    but we are getting there.

    Written by Kirill Radzikhovskyy
"""

import re,sys,os
from libkita import *

# change this variable as much as you want, still I am the one who decides which version it is.
KITAMAN_VER="1.0rc_nooneknows"

class KitamanEngine(object):
  "Main Heart of Kitaman"
  
  goal=""
  "Contains a name of goal target, set it before running the engine"
  
  goal_dependencies=[]
  "list of Kita() objects each of them to be processed in order to get to goal"
  
  module=None
  "Module used to process a current Kita() object"

  options={"fetch":True,"build":True,"install":True,"deep":False,"deepest":False,"force":False,"search":False,"remove":False}
  "Engine Options: tell engine with which options it should run"
  # future plans to expand to:"force-download force-build force-install"

  def __load_module__(self,name):
    "Loads a module for processing kitafile, by a given name"
    self.module=__import__(name)

  def load_module_for(self,name):
    "loads module for a given kita_file"
    f=open(name,"r").read()
    pat=re.compile(r'KITA_TYPE=\"(.*?)\"\n')
    results=re.findall(pat,f)
   
    # Fallback to default module "make1" (if we have to)
    if len(results)==0:
      self.__load_module__("make1")
    else:
      self.__load_module__(results[0])
    #### Please restore next lines in the future
    # in the beautiful and bright future, we will not accept kitafiles without
    # strict statment of its type
    #
    # this is a check for presence of KITA_TYPE var in kitafile
    #if len(results)==0:
    #  kita_error ("No module found for "+name)
    #self.__load_module__(results[0])


  def generate_goal_list(self):
    "Generating a list for engine to run through"
    # Are we searching ?
    if self.options["search"]:
    
      # we will search though our sources list file
      files_list=open("/var/kitaman/sources.list").read()

      pattern=re.compile("<a href=\"(?:.*?)\">(.*?)</a>")

      results=re.findall(pattern,files_list)
      for i in results:
        if self.goal in i:
          print i
      
      sys.exit()

      return
    # Are we removing ?
    if self.options["remove"]:
      list=find_kita_files(self.goal)
      for i in list:
        self.load_module_for(i)
        temp=self.module.Kita(i)
        self.goal_dependencies.append(temp)
      return

    # Getting kitafile for goal
    file_name=self.get_kita_file_from_name(self.goal)
    
    #Loading needed module
    self.load_module_for(file_name)
  
    # Creating Kita Object for goal
    temp=self.module.Kita(file_name)
    
    # Making dependencies list
    print "Generating Dependencies"
    # this function is the main most important part of kitaman : recursive magic
    self.make_dependencies_list(temp)

    # If we are not in "deepest" mode, we should remove already installed packages from our list
    if not self.options["deepest"]:
      self.check_installed_deps()

  def run(self):
    "Runs the engine, goest though the list, and one by one performs needed actions on it"
    for i in self.goal_dependencies:
      set_terminal_title("%s of %s: %s" % (self.goal_dependencies.index(i)+1,len(self.goal_dependencies),i.info["NAME-VER"]))
      kita_print(str(self.goal_dependencies.index(i)+1)+" of "+str(len(self.goal_dependencies))+" "+bold(i.info["NAME-VER"]))
      if self.options["fetch"]:
        kita_print("Download Files")
        if self.options["force"] or not i.downloaded():
          if not i.download():
            kita_error("Download Failed "+i.info["NAME-VER"])
      if self.options["build"]:
        kita_print("Building Binary")
        if not i.build():
          kita_error("Build Failed " + i.info["NAME-VER"])
      if self.options["install"]:
        kita_print("Installing binary into / ")
        if not i.install():
          kita_error("Install Failed " + i.info["NAME-VER"])
        else:
          i.record_installed()
      if self.options["remove"]:
        kita_print("Removing "+ i.info["NAME-VER"])
        i.remove()
    set_terminal_title("Finished !!!")


  def get_kita_file_from_name(self,name):
    """For a given name returns path to kitafile(if found)
    possible arguments: plain package name
                        package name with version
                        >package name with version """
    # First lets check what kind of name did we get (its tricky)
    if name[0]=="=":
      print "package with version"
      print "TODO FIXME"
    else:
      if name[0] in "<>":
        print "Comparison test version, Please develop me later"
      else:
        list=find_kita_files(name)

        #If we didnt find any kitafiles for a give name, we should quit
        if len(list)==0:
          kita_error("No kitafiles found for "+name)
        file_name=get_highest_version(list)
        return file_name

  def check_installed_deps(self):
    "Checks given list of dependencies,and returns list of still needed deps based on rule of eliminating packages that are already installed"
    new_list=[]
    for i in self.goal_dependencies:
      if not i.installed():
        new_list.append(i)
      else:
        print bold(i.info["NAME-VER"]),"is already installed"

    self.goal_dependencies=new_list

  def find_all_without_parent(self):
    "Shows ALL packages that are not dependencies of any other packages"

    # First we get list of all the kitafiles in Repositories
    list=[]
    for repo in get_repos_list():
      for kita_file in os.listdir(repo):
        if kita_file[-5:] == ".kita":
          list.append(repo+kita_file)

    #Now we load Kita Objects
    info_list=[]
    for i in list:
      self.load_module_for(i)
      temp=self.module.Kita(i)
      info_list.append(temp)

    #Now n*n magic, for each package check if any package depends on it
    for i in info_list:
      has_parent=False
      for a in info_list:
        if i.info["NAME"] in a.info["DEPEND"]:
          has_parent=True
      # if package has no one depending on it, Print it, so we know about it
      if not has_parent:
        print i.info["NAME"]
  
  def print_goal_list(self):
    for i in self.goal_dependencies:
      x=str(self.goal_dependencies.index(i)+1)
      y=str(len(self.goal_dependencies))
      kita_print(x+black(" of ")+green()+y+" "+bold(i.info["NAME-VER"]))

  def make_dependencies_list(self,package,parent=None,list=[]):
    """To iterate is human, to recurse divine.
    This absolutely state of the art algorithm
    recursivly generates a list of dependencies"""
 
    #if dependecy is already installed , we dont needto go further
    if not self.options["deep"] and package.installed(): 
      return list
    #If dependency already in the list, then it means we already been here, no need to continue
    for i in list:
      if package.info["NAME-VER"] == i.info["NAME-VER"]: 
        return list

    # if list is empty we should add the parent program to the list
    if len(list)==0:
      list.append(package)
    else:
      # Find where to append a dependency
      # Golden rule, Dependency must be always earlier in the list than its parent
      where_to_append=list.index(parent)
      list.insert(where_to_append,package)
    #For each dependency that is not yet in the list we do recursive magic
    for i in package.info["DEPEND"]:
      file_name=self.get_kita_file_from_name(i)
      self.load_module_for(file_name)
      temp=self.module.Kita(file_name)
      list=self.make_dependencies_list(temp,package,list)
    self.goal_dependencies=list
    return list
  
  def parse_argv_to_options(self):
    "Parse options given in argv into engine equivalent options"
    #Get rid of itself in argv
    del sys.argv[0]

    for i in sys.argv:
      if i in ["--help","-h"]:
        print_help(KITAMAN_VER)
        sys.exit()
      if i in ["--sync"]:
        update_sources_list()
        sys.exit()
      if i in ["--pretend","-p"]:
        self.options["install"]=False
        self.options["build"]=False
        self.options["fetch"]=False
      if i in ["--remove","-r"]:
        self.options["install"]=False
        self.options["build"]=False
        self.options["fetch"]=False
        self.options["remove"]=True
      if i in ["--search","-s"]:
        self.options["install"]=False
        self.options["build"]=False
        self.options["fetch"]=False
        self.options["search"]=True
      if i in ["--fetch","-f"]:
        self.options["install"]=False
        self.options["build"]=False
        self.options["fetch"]=True
      if i in ["--deep","-d"]:
        self.options["deep"]=True
      if i in ["--deepest","-D"]:
        self.options["deep"]=True
        self.options["deepest"]=True
      if i in ["--force","-F"]:
        self.options["force"]=True
      if i == "--no-parent":
        self.find_all_without_parent()
        sys.exit()

    # clean up argv
    # cheap work around, FIXME later please
    for a in sys.argv:
      for i in sys.argv:
        if i[0]=="-":
          del sys.argv[sys.argv.index(i)]


# This is the entry point
# This is the entry point
# This is the entry point
# This is the entry point
# This is the entry point
# This is the entry point

# if ran without arguments, show basic usage help message
if len(sys.argv)==1:
 print_help(KITAMAN_VER) 
else:
  # Gentelman, start your Engines!!!
  engine=KitamanEngine()
  
  #Parsing command line
  engine.parse_argv_to_options()

# For everything that is left in argv we run our engine
  for i in sys.argv:
    engine.goal=i
    engine.generate_goal_list()
    engine.print_goal_list()
    raw_input("Everything ok ? (Enter / Ctrl+D) : ")
    engine.run()

# This is the end of File :-)
# Thank you for reading !!!
