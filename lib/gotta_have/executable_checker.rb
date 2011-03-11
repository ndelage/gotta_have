module GottaHave

  class ExecutableChecker
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
      # we remove any dots or dashes from the version numbers so we can do a
      # simple comparison on the two values (as integers)
      installed = ExecutableChecker.normalize_version( installed )
      required = ExecutableChecker.normalize_version( required )
      
      if allow_newer
        return installed >= required
      else
        return required == installed
      end
    end

    def self.normalize_version( version )
      # drop any non decimal or a-z characters from the version
      version = version.gsub( /[^\d|a-z|A-Z]/, '' )

      normalized = ""
      # since some version numbers include a letter (e.g. 1.1a) we convert all
      # chars in the version str to their ascii codes.
      version.each_byte{ |b| normalized += b.to_s }
      normalized.to_i
    end
    
  end
  
end

