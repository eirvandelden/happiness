require "test_helper"

class JavascriptPackageManagerTest < ActiveSupport::TestCase
  ROOT = Rails.root
  THIS_FILE = "test/lib/javascript_package_manager_test.rb"
  # The change folder documents the migration itself, so it names yarn.
  EXCLUDED_PATHS = [ THIS_FILE, "docs/changes/replace-yarn-with-npm" ].freeze

  test "uses package-lock.json" do
    assert_predicate ROOT.join("package-lock.json"), :exist?
  end

  test "has no yarn lockfile" do
    assert_not ROOT.join("yarn.lock").exist?
  end

  test "has no bin/yarn" do
    assert_not ROOT.join("bin/yarn").exist?
  end

  test "bin/setup installs JavaScript packages with npm before preparing the database" do
    setup = ROOT.join("bin/setup").read

    assert_includes setup, 'system!("npm install")'
    assert_operator setup.index('system!("npm install")'), :<, setup.index("db:prepare")
  end

  test "names yarn nowhere outside data" do
    matches = tracked_files_naming_yarn - EXCLUDED_PATHS.flat_map { |path| matching(path) }

    assert_empty matches, "Tracked files still name yarn: #{matches.join(', ')}"
  end

  private

  def tracked_files_naming_yarn
    Dir.chdir(ROOT) { `git grep -i -l yarn`.split("\n") }
  end

  def matching(path)
    tracked_files_naming_yarn.select { |file| file == path || file.start_with?("#{path}/") }
  end
end
