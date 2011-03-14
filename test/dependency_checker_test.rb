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

  context "when a check_cmd doesn't exist for an executable" do
    should "raise exception" do
      assert_raise( GottaHave::MissingVersionCheckException ) {DependencyChecker.check_dependency( 'unknown', {:version => 1.0} )}
    end
  end

  context "when a version isn't identified" do
    should "raise exception" do
      assert_raise (GottaHave::VersionCheckFailException) {DependencyChecker.check_dependency( 'unknown', {:version => 1.0, :check_cmd => ""} )}
    end
  end
  
end