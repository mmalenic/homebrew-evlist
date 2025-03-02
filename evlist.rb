# frozen_string_literal: true

# The homebrew formula for evlist.
class Evlist < Formula
  desc 'List input event devices on Unix'
  homepage 'https://github.com/mmalenic/evlist'
  head 'https://github.com/mmalenic/evlist.git', branch: 'main'
  url 'https://github.com/mmalenic/evlist/archive/refs/tags/v1.0.0.tar.gz'
  sha256 'ebdf35057571ad82c3263ff758217297d6f198fa05bc9b961b3d5a8a7b0731f5'
  license 'MIT'

  depends_on 'cmake' => :build
  depends_on 'cli11'

  resource 'toolbelt' do
    url 'https://github.com/mmalenic/cmake-toolbelt/archive/refs/tags/v0.3.0.tar.gz'
    sha256 '562b36ded37f884494b0d74bd13f4f4a6494521ee1ec9adff546922c9c8be649'
  end

  fails_with :clang do
    version '18'
    cause 'requires C++23 support'
  end

  fails_with :gcc do
    version '13'
    cause 'requires C++23 support'
  end

  def install
    destination = buildpath / 'toolbelt_src'

    resource('toolbelt').stage do
      destination.install Dir['*']
    end

    system 'cmake', '-S', '.', '-B', 'build', '-DEVLIST_BUILD_BIN=TRUE', '-DEVLIST_INSTALL_BIN=TRUE',
           '-DEVLIST_INSTALL_LIB=TRUE', "-Dtoolbelt_SOURCE_DIR=#{destination}", *std_cmake_args
    system 'cmake', '--build', 'build'

    system 'cmake', '--install', 'build'
  end

  test do
    assert shell_output("#{bin}/evlist") != ''
    assert_equal "\"NAME\",\"DEVICE_PATH\",\"BY_ID\",\"BY_PATH\",\"CAPABILITIES\"\n",
                 shell_output("#{bin}/evlist --format csv --filter device_path ''")

    (testpath / 'test.cpp').write <<~CPP
      #include <evlist/evlist.h>

      int main() {
        evlist::InputDeviceLister list{};
        auto devices = list.list_input_devices();#{' '}

        return !devices.has_value();
      }
    CPP

    system ENV.cxx, 'test.cpp', '-std=c++23', "-L#{lib}", '-levlist', '-o', 'test'
    system './test'
  end
end
