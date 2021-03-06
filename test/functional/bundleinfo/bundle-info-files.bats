#!/usr/bin/env bats

# Author: Castulo Martinez
# Email: castulo.martinez@intel.com

load "../testlib"

global_setup() {

	create_test_environment "$TEST_NAME"
	create_bundle -n test-bundle1 -f /file_1,/foo/file_2 "$TEST_NAME"
	create_bundle -n test-bundle2 -f /file_3,/bar/file_4 "$TEST_NAME"
	# add test-bundle2 as a dependency of test-bundle1
	add_dependency_to_manifest "$WEBDIR"/10/Manifest.test-bundle1 test-bundle2
	create_version "$TEST_NAME" 20 10
	update_bundle "$TEST_NAME" test-bundle1 --header-only
	update_bundle "$TEST_NAME" test-bundle2 --add /file_5

}

test_setup() {

	# do nothing, just overwrite the lib test_setup
	return

}

test_teardown() {

	# do nothing, just overwrite the lib test_setup
	return

}

global_teardown() {

	destroy_test_environment "$TEST_NAME"

}

@test "BIN008: Show the files that are part of a bundle" {

	# bundle-info --files show the files that are part of that bundle
	# it doesn't include files from dependencies

	run sudo sh -c "$SWUPD bundle-info $SWUPD_OPTS test-bundle1 --files"

	assert_status_is "$SWUPD_OK"
	expected_output=$(cat <<-EOM
		_______________________________
		 Info for bundle: test-bundle1
		_______________________________
		Status: Not installed
		Latest available version: 20
		Bundle size:
		 - Size of bundle: .* KB
		 - Maximum amount of disk size the bundle will take if installed \(includes dependencies\): .* KB
		Files in bundle:
		 - /usr/share/clear/bundles/test-bundle1
		 - /foo/file_2
		 - /foo
		 - /file_1
		Total files: 4
	EOM
	)
	assert_regex_is_output "$expected_output"

}

@test "BIN009: Show the files that are part of a bundle and its dependencies" {

	# bundle-info --files show the files that are part of that bundle, if
	# the --includes flag is also used it doest include files from dependencies

	run sudo sh -c "$SWUPD bundle-info $SWUPD_OPTS test-bundle1 --files --dependencies"

	assert_status_is "$SWUPD_OK"
	expected_output=$(cat <<-EOM
		_______________________________
		 Info for bundle: test-bundle1
		_______________________________
		Status: Not installed
		Latest available version: 20
		Bundle size:
		 - Size of bundle: .* KB
		 - Maximum amount of disk size the bundle will take if installed \(includes dependencies\): .* KB
		Direct dependencies \(1\):
		 - test-bundle2
		Files in bundle \(includes dependencies\):
		 - /bar
		 - /bar/file_4
		 - /file_1
		 - /file_3
		 - /foo
		 - /foo/file_2
		 - /usr/share/clear/bundles/test-bundle1
		 - /usr/share/clear/bundles/test-bundle2
		Total files: 8
	EOM
	)
	assert_regex_is_output "$expected_output"

}

@test "BIN010: Show the files that are part of a bundle and its dependencies for a specific version" {

	# the --version flag can be appended to the command to select a specific version

	run sudo sh -c "$SWUPD bundle-info $SWUPD_OPTS test-bundle1 --files --dependencies --version latest"

	assert_status_is "$SWUPD_OK"
	expected_output=$(cat <<-EOM
		_______________________________
		 Info for bundle: test-bundle1
		_______________________________
		Status: Not installed
		Latest available version: 20
		Bundle size:
		 - Size of bundle: .* KB
		 - Maximum amount of disk size the bundle will take if installed \(includes dependencies\): .* KB
		Direct dependencies \(1\):
		 - test-bundle2
		Files in bundle \(includes dependencies\):
		 - /bar
		 - /bar/file_4
		 - /file_1
		 - /file_3
		 - /file_5
		 - /foo
		 - /foo/file_2
		 - /usr/share/clear/bundles/test-bundle1
		 - /usr/share/clear/bundles/test-bundle2
		Total files: 9
	EOM
	)
	assert_regex_is_output "$expected_output"

}
