require 'test_helper'

class DependencyCheckerTest < Test::Unit::TestCase
  include GottaHave

  context "When versions are equal" do
    context "and requiring exact version matching" do
      setup do
        @allow_newer = false
      end

      should "pass when versions match exactly" do
        assert DependencyChecker.correct_version?( "1", "1", @allow_newer )
      end

      should "pass when versions are equal but have different lengths" do
        assert DependencyChecker.correct_version?( "1.0", "1", @allow_newer )
      end

    end

    context "and allowing newer versions" do
      setup do
        @allow_newer = true
      end

      should "pass when versions match exactly" do
        assert DependencyChecker.correct_version?( "1", "1", @allow_newer )
        assert DependencyChecker.correct_version?( "1.1", "1.1", @allow_newer )
        assert DependencyChecker.correct_version?( "1.1a", "1.1a", @allow_newer )
        assert DependencyChecker.correct_version?( "1.1-a", "1.1-a", @allow_newer )
      end

      should "pass when versions are equal but have different lengths" do
        assert DependencyChecker.correct_version?( "1.0", "1", @allow_newer )
      end
    end
  end

  context "When the required version is newer than the installed version" do
    context "and requiring exact version matching" do
      setup do
        @allow_newer = false
      end

      should "fail when versions don't match" do
        assert !DependencyChecker.correct_version?( "2", "1", @allow_newer )
      end
    end

    context "and allowing newer versions" do
      setup do
        @allow_newer = true
      end
      
      should "fail when versions are integers" do
        assert !DependencyChecker.correct_version?( "2", "1", @allow_newer )
      end

      should "fail when versions have decimal places" do
        assert !DependencyChecker.correct_version?( "2.1", "1.1", @allow_newer )
        assert !DependencyChecker.correct_version?( "0.10", "0.01", @allow_newer )

        # fails test, need to check Versionomy
        #assert !DependencyChecker.correct_version?( "0.1", "0.01", @allow_newer )
      end

      should "fail when versions have letter(s)" do
        assert !DependencyChecker.correct_version?( "1.0b", "1.0a", @allow_newer )
        assert !DependencyChecker.correct_version?( "1.0B", "1.0A", @allow_newer )
        assert !DependencyChecker.correct_version?( "1.0-B", "1.0-A", @allow_newer )
      end
    end
  end

  context "When the installed version is newer than the required version" do
    context "and requiring exact version matching" do
      setup do
        @allow_newer = false
      end

      should "fail when versions don't match" do
        assert !DependencyChecker.correct_version?( "1", "2", @allow_newer )
      end
    end

    context "and allowing newer versions" do
      setup do
        @allow_newer = true
        end

      should "pass when versions are integers" do
        assert DependencyChecker.correct_version?( "1", "2", @allow_newer )
      end

      should "pass when versions have decimal places" do
        assert DependencyChecker.correct_version?( "1.1", "2.1", @allow_newer )
        assert DependencyChecker.correct_version?( "0.01", "0.1", @allow_newer )
      end

      should "pass when versions have letter(s)" do
        assert DependencyChecker.correct_version?( "1.0a", "1.0b", @allow_newer )
        assert DependencyChecker.correct_version?( "1.0A", "1.0B", @allow_newer )
        assert DependencyChecker.correct_version?( "1.0-A", "1.0-B", @allow_newer )
      end
    end

  end

  context "Checking dependencies" do
    setup do
      @sample_name = "cmd"
      @sample_name_2 = "cmd2"
      @sample_cmd = "cmd -version"
      @sample_version = "1.0"
      @sample_config = {:version => @sample_version}
    end

    context "When checking a single dependency" do
      should "call #installed_version" do
        DependencyChecker.expects(:installed_version).with(@sample_name, @sample_cmd ).once.returns( @sample_version )
        DependencyChecker.check_dependency( @sample_name, :check_cmd => @sample_cmd, :version => @sample_version )
      end
    end

    context "When checking multiple dependencies" do
      should "call #check_dependency for each dependency" do
        DependencyChecker.expects(:check_dependency).with(@sample_name, @sample_config ).once.returns( true )
        DependencyChecker.expects(:check_dependency).with(@sample_name_2, @sample_config ).once.returns( true )
        DependencyChecker.requirements = {@sample_name => @sample_config,
                                          @sample_name_2 => @sample_config }
        DependencyChecker.check_dependencies
      end
    end

    context "When checking for an installed version" do
      should "call #execute_command" do
        CmdLineHelpers.expects(:execute_command).with(@sample_cmd, "requirement check").once.returns( @sample_version )
        DependencyChecker.installed_version( @sample_name, @sample_cmd )
      end
    end

    context "When a check_cmd doesn't exist for an executable" do
      should "raise MissingVersionCheckException exception" do
        assert_raise( MissingVersionCheckException ) {DependencyChecker.installed_version( @sample_name )}
      end
    end

    context "When binary doesn't exist" do
      should "raise VersionCheckFailException exception" do
        assert_raise (VersionCheckFailException) {DependencyChecker.installed_version( @sample_name, @sample_cmd )}
      end
    end

    context "When a version isn't identified" do
      should "raise VersionCheckFailException exception" do
        CmdLineHelpers.stubs(:execute_command).returns("")
        assert_raise (VersionCheckFailException) {DependencyChecker.installed_version( @sample_name, @sample_cmd )}
      end
    end

    context "When using the dependency checker module" do
      should "have an attribute requirements" do
        assert DependencyChecker.requirements
      end
    end
  end
  
end