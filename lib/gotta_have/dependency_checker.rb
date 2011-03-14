module GottaHave

  module DependencyChecker

    class << self; attr_accessor :requirements end
    @requirements = {}

    VERSION_CHECK_COMMANDS = {'exiftool' => "exiftool -ver",
                              'convert' => "convert -version | grep ^Version | awk '{print $3}'",
                              'identify' => "identify -version | grep ^Version | awk '{print $3}'",
                              'macunpack' => "macunpack -V  2>&1 | grep ^Version | awk '{print $2}'",
                              'unzip' => "unzip -v | head -n 1 | awk '{print $2}'",
                              'file' => "file -v 2>&1 | head -n 1 | tr -cd '[[:digit:]\.]'" }

    def self.check_dependencies
      for executable in self.requirements.keys
        self.check_dependency( executable, self.requirements[executable] )
      end
    end

    def self.check_dependency( executable, config )
      # find the installed version
      installed_version = self.installed_version( executable, config[:check_cmd] )
      
      unless self.correct_version?( config[:version], installed_version, config[:allow_newer] )
        raise GottaHave::RequiredUtilsException, "Missing or incorrect version of utility '#{executable}', required #{config[:version]}, found #{installed_version}"
      end
    end

    def self.installed_version( executable, version_check_override=nil )
      check = version_check_override || VERSION_CHECK_COMMANDS[executable]
      if check
        version = CmdLineHelpers.execute_command( check, "requirement check" ).strip
        if version.length == 0
          raise GottaHave::VersionCheckFailException, "Unable to determine the installed version of #{executable}"
        else
          return version
        end
      else
        raise GottaHave::MissingVersionCheckException, "No way to look up the installed version for #{executable}"
      end
    end

    def self.correct_version?( required, installed, allow_newer=false )

      required = self.split_version( required )
      installed = self.split_version( installed )
      
      if allow_newer
        return (installed <=> required) >= 0
      else
        return required == installed
      end
    end

    def self.split_version( version )
      version.split( /\.|-|_/ ).map{ |s| s }
    end
  end
  
end

