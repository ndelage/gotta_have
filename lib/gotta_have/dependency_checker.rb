module GottaHave

  module DependencyChecker
    require 'versionomy'

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

      return true
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
      if check.nil?
        raise GottaHave::MissingVersionCheckException, "No way to look up the installed version for #{executable}"
      end

      # CmdLineHelpers will throw a generic exception if we don't have a clean (0)
      # return code, so we catch the generic exception and raise our own
      begin
        version = CmdLineHelpers.execute_command( check, "requirement check" ).strip
        if version.length == 0
          raise GottaHave::VersionCheckFailException, "Unable to determine the installed version of #{executable}"
        else
          return version
        end
      rescue
        raise GottaHave::VersionCheckFailException, "Unable to determine the installed version of #{executable}"
      end
    end

    def self.correct_version?( required, installed, allow_newer=false )
      required = Versionomy.parse( required )
      installed = Versionomy.parse( installed )
      
      if allow_newer
        return installed >= required
      else
        return required == installed
      end
    end

  end
  
end

