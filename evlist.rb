# frozen_string_literal: true

# The homebrew formula for evlist.
class Evlist < Formula
  desc "List input event devices on Linux"
  homepage "https://github.com/mmalenic/evlist"
  url "https://github.com/mmalenic/evlist/archive/refs/tags/v1.0.5.tar.gz"
  sha256 "45159914d2b248d3a04876b8c1e966844410998d5af15f1ba5e0da1fcb325426"
  license "MIT"
  head "https://github.com/mmalenic/evlist.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/mmalenic/evlist"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4420f83932785231bb92d83da9a101aa9c984da7b32f5ac0e9ebddea02c4c630"
  end

  depends_on "cmake" => :build
  depends_on "cli11"

  fails_with :gcc do
    version "13"
    cause "requires C++23 support"
  end

  resource "toolbelt" do
    url "https://github.com/mmalenic/cmake-toolbelt/archive/refs/tags/v0.3.1.tar.gz"
    sha256 "cbe46d02b9e49c9ba592187e3b8df4b6e503d871b5e1851f6ed0520ad0661943"
  end

  def install
    destination = buildpath / "toolbelt_src"

    resource("toolbelt").stage do
      destination.install Dir["*"]
    end

    system "cmake", "-S", ".", "-B", "build", "-DEVLIST_BUILD_BIN=TRUE", "-DEVLIST_INSTALL_BIN=TRUE",
           "-DEVLIST_INSTALL_LIB=TRUE", "-Dtoolbelt_SOURCE_DIR=#{destination}", *std_cmake_args
    system "cmake", "--build", "build"

    system "cmake", "--install", "build"
  end

  test do
    assert shell_output(bin / "evlist") != ""
    assert_equal "\"NAME\",\"DEVICE_PATH\",\"BY_ID\",\"BY_PATH\",\"CAPABILITIES\"\n",
                 shell_output(bin / "evlist --format csv --filter device_path ''")

    (testpath / "test.cpp").write <<~CPP
      #include <evlist/evlist.h>

      int main() {
        evlist::InputDeviceLister list{};
        auto devices = list.list_input_devices();

        return !devices.has_value();
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++23", "-L#{lib}", "-levlist", "-o", "test"
    system "./test"
  end
end
