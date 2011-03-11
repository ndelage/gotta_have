require 'test_helper'

class ExecutableCheckerTest < Test::Unit::TestCase
  include GottaHave
  
  context "When forcing exact version match" do
    should "pass version check when versions match exactly" do
      assert ExecutableChecker.correct_version?( "1", "1" )
    end

    should "fail version check when versions don't match" do
      assert !ExecutableChecker.correct_version?( "1", "2" )
    end
  end

  context "When allowing newer versions" do
    should "pass version check when versions match exactly" do
      assert ExecutableChecker.correct_version?( "1", "1", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.1", "1.1", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.1a", "1.1a", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.1-a", "1.1-a", allow_newer=true )
    end

    should "pass version check when installed version is newer" do
      assert ExecutableChecker.correct_version?( "1", "2", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.0", "2.0", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.1", "2.1", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.0a", "1.0b", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.0A", "1.0B", allow_newer=true )
      assert ExecutableChecker.correct_version?( "1.0-A", "1.0-B", allow_newer=true )
    end

    should "fail version check when installed version is older" do
      assert !ExecutableChecker.correct_version?( "2", "1", allow_newer=true )
      assert !ExecutableChecker.correct_version?( "2.0", "1.0", allow_newer=true )
      assert !ExecutableChecker.correct_version?( "2.1", "1.1", allow_newer=true )
      assert !ExecutableChecker.correct_version?( "1.0b", "1.0a", allow_newer=true )
      assert !ExecutableChecker.correct_version?( "1.0B", "1.0A", allow_newer=true )
      assert !ExecutableChecker.correct_version?( "1.0-B", "1.0-A", allow_newer=true )
    end
  end

  context "when a check_cmd doesn't exist for an executable" do
    should "raise exception" do
      assert_raise( GottaHave::MissingVersionCheckException ) {ExecutableChecker.check_dependency( 'unknown', {:version => 1.0} )}
    end
  end

  context "when a version isn't identified" do
    should "raise exception" do
      assert_raise (GottaHave::VersionCheckFailException) {ExecutableChecker.check_dependency( 'unknown', {:version => 1.0, :check_cmd => ""} )}
    end
  end
  
end


#comparing: 2.0b3, 2.0b3
#comparing: 6.5.9-9, 6.5.9-9
#comparing: 0.2.0, 0.2.0
#comparing: 4.21, 5.04
#comparing: 421, 5.04
#comparing: 8.42, 8.42
#comparing: 5.52, 5.52
#comparing: 552, 5.52
#comparing: 6.5.9-9, 6.5.9-9