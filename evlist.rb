class Evlist < Formula
  desc "List input event devices on Unix"
  homepage "https://github.com/mmalenic/evlist"
  head "https://github.com/mmalenic/evlist.git", branch: "main"
  url "https://github.com/mmalenic/evlist/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "ebdf35057571ad82c3263ff758217297d6f198fa05bc9b961b3d5a8a7b0731f5"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "cli11"

  def build_evlist(*cmake_args)
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args, *cmake_args
    system "cmake", "--build", "build"
  end

  def install
    build_evlist "-DHOMEBREW_ALLOW_FETCHCONTENT=ON"
    system "cmake", "--install", "build"
  end

  test do
    build_evlist "-DHOMEBREW_ALLOW_FETCHCONTENT=ON", "-DBUILD_TESTING=TRUE"

    Dir.chdir "build/Release" do
      system "./evlisttest"
    end
  end
end
