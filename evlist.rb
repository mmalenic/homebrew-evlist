# frozen_string_literal: true

# The homebrew formula for evlist.
class Evlist < Formula
  desc "List input event devices on Linux"
  homepage "https://github.com/mmalenic/evlist"
  url "https://github.com/mmalenic/evlist/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "e1e34d0e6ef94cf5905551f1a6046fac357e0f7f20f1cdf4960c5e89d54132b8"
  license "MIT"
  head "https://github.com/mmalenic/evlist.git", branch: "main"

  sig { params(block: T.proc.bind(BottleSpecification).void).void }

  bottle do
    root_url "https://github.com/mmalenic/evlist/releases/download/v1.0.2"
    sha256 cellar:       :any_skip_relocation,
           x86_64_linux: "1c6a6586e700201fef630362dcc74164487996d14b856ce2a7c93d011b3b6013"
  end

  depends_on "cli11"
  depends_on "cmake" => :builds

  fails_with :clang do
    version "18"
    cause "requires C++23 support"
  end

  fails_with :gcc do
    version "13"
    cause "requires C++23 support"
  end

  resource "toolbelt" do
    url "https://github.com/mmalenic/cmake-toolbelt/archive/refs/tags/v0.3.0.tar.gz"
    sha256 "562b36ded37f884494b0d74bd13f4f4a6494521ee1ec9adff546922c9c8be649"
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
