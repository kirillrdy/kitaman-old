"Functions used by kitaman"

import re,sys,os,urllib2

def get_version(name):
  """ Gets a string and returns a version 
      eg get_version("linux-2.6")=="2.6" 
      and linux-2.6.tar.gz=="2.6"
  """
  
  #TODO , change order of if statements , more logical
  version=name[name.rfind("-")+1:]
  if version[:2]=="rc":
    version=name[name.rfind("-",0,len(name)-13)+1:]
  if version[-8:]==".tar.bz2":
    version=version[:-8]
  if version[-7:]==".tar.gz":
    version=version[:-7]

  return version

def update_sources_list():
  """
    For each repostory listed in kitaman.sources
    Downloads and saves list of files availible for download
  """
  f=open("/etc/kitaman.sources").read()
  f=f[:-1]
  f=f.split("\n")
  sources_file=open("/var/kitaman/sources.list","w")

  for i in f:
    kita_print ("Updating "+i)
    text=urllib2.urlopen(i).read()
    pattern=re.compile("<a href=\"(?:.*?)(?:.tar.gz|.tar.bz2)\">(.*?)</a>")
    results=re.findall(pattern,text)
    new_text=""
    for ii in results:
      new_text=new_text+"<a href=\"%s\">%s</a>\n" % (i+ii,ii)
    sources_file.write(new_text)

  sources_file.close()

def get_name(name):
  """Gets a name of a package from a full package name + version
  For example get_name("linux-2.6")="linux"
  also get_name("/usr/muhaha/linux-2.6")="linux"
  and get_name("/linux")="linux"
  """
  if name.rfind("/")!=-1:
    name=name[name.rfind("/")+1:]
  if name.rfind(".")!=-1:
    return name[0:name.rfind(".")]
  return name

def find_kita_files(name):
    "For a given name, returns a list of full filename of kitafiles with paths"

    list=[]
    "a list of all availible versions"

    for repo in get_repos_list():
      for kita_file in os.listdir(repo):
        if name==get_name(kita_file):
            list.append(repo+kita_file)
    return list


def str_to_int_pariah_style(something):
  "Oh i am great"
  if something.isdigit():
    return int(something)
  if something[-3:-1]=="rc":
    return int(something[:-3])-100
  #return something
  # FIXME There is a potential bug in this function,please fix me,
  # make me being able to handle letters abcdef as version

def max_version(list):
  "its like pythons max but something to compare version strings"
  new_list=[]
  max=[]
  max_string_ver=""
  for i in list:
    version_list=i.split(".")
    version_list=map(str_to_int_pariah_style,version_list)

    if tuple(version_list)>tuple(max):
      max_string_ver=i
      max=version_list
  
  return max_string_ver

  
def get_highest_version(list):
    "From a given lists of kitafiles, returns list's item with the highest version"
    #NOTE there is a bug in this function 
    #due to shorcomming of python strings comparisment "0.9.0" > "0.10.0" == True
    #FIXME , i know how to fix this, use code from max_version function
    #however this function is due to be depricated
    
    max=""

    highest=""
    for i in list:
      version=get_version(i).replace(".","")
      if version>max:
        max=version
        highest=i
    return highest   

def load_kita_config(name):
  "Loads a config file, and returns dictionary"
  f=open(name,"r").read()
  pat=re.compile(r'(.*?)=(.*?)\n')
  results=re.findall(pat,f)
  dic={}
  for i in results:
    dic[i[0]]=i[1]
  return dic

def get_repos_list():
  "Returns a list of repositories"
  f=open("/etc/kitaman.repos").read()
  f=f.split("\n")

  #got to delete last item, since its blank, its a left overs from .split
  # note if u turn ur head 90 degrees anti clockwise , it will look like a smiley face
  f=f[:-1]
  return f

def kita_error(message):
  "Standart way for kitaman to notify user of Error"
  set_terminal_title("Error")
  print red()
  print "ERROR !!!      ||      ERROR !!!"
  print "ERROR !!!      ||      ERROR !!!"
  print "ERROR !!!      WW      ERROR !!!"
  print
  print bold(red("===>")+black(bold(message))+red(bold("<===")))
  print red()
  print "ERROR !!!      MM      ERROR !!!"
  print "ERROR !!!      ||      ERROR !!!"
  print "ERROR !!!      ||      ERROR !!!"
  print black()
  #Every failed program must leave with dignity 1 
  sys.exit(1)


def color(i):
  "Returns an escape sequence for given color"
  return"\033[%sm" % (i)

def black(str=""):
  return color(0)+str
def red(str=""):
  return color(31)+str
def green(str=""):
  return color(32)+str
def brown(str=""):
  return color(33)+str
def blue(str=""):
  return color(34)+str
def violet(str=""):
  return color(35)+str
def crayon(str=""):
  return color(36)+str
def gray(str=""):
  return color(37)+str
def bold(str=""):
  return color(1)+str+color(0)

def set_terminal_title(str):
  print "\033]0;%s\007" % (str)

def print_help(ver):
  print

  print """
  Welcome to Kitaman Package Manager - %s - Our future has been decided
    Usage:-
      kitman [OPTIONS] package

      Options:
        -h  --help      : Displays this message
            --install   : (Default) installs package
        -r  --remove    : removes package
        -f  --fetch     : fetches all needed files 
        -F  --force     : ignores already downloaded files, and downloads them anyways
        -s  --search    : searches for a string in package name or description
        -p  --pretend   : Pretends to install a package, shows all steps done to build a package
        -d  --deep      : When calculating dependencies dont stop recursion on already installed dependencies
        -D  --deepest   : Same as --deep but in addition ingnores any installed programs
        --no-parent     : Shows all packages without parent
        --sync          : Syncs sources list
  
  """ % ver
  print

def kita_print(str):
  print green()+">>> "+str+black()

#Load config file
kita_config=load_kita_config("/etc/kitaman.conf")

