module GottaHave
  class RequiredUtilsException < Exception
  end

  class MissingVersionCheckException < Exception
  end

  class VersionCheckFailException < Exception
  end
end