# frozen_string_literal: true

# 这是您的应用程序的 Homebrew Formula。
# 它能让用户通过简单的 `brew install` 命令来安装您的 GUI 应用。
class Polarimeter < Formula
  # --- (1) 基本信息 ---
  desc "一款基于 Rust 的偏振计图形界面应用"
  homepage "https://github.com/MJ23333/Rust-Polarimeter" # 替换成您的项目主页
  url "https://github.com/MJ23333/Rust-Polarimeter/archive/refs/tags/test6.tar.gz" # 替换成您的 release 压缩包 URL
  sha256 "34d92fa5b9ae2c44c93a1e6a64dfcaf3fad63203e6012f5984c88c8c156220b3" # 替换成压缩包的 SHA256
  version "0.0.1"

  # --- (2) 依赖项 ---
  depends_on "rust" => :build
  depends_on "opencv"

  # --- (3) 安装逻辑 ---
  def install
    # 定义变量，便于维护
    app_name = "Polarimeter"
    executable_name = "rust_polarimeter_gui"
    camera_usage_description = "此应用需要访问摄像头以进行实时图像处理和分析。"
    if OS.mac?
      xcode_path = `xcode-select --print-path`.strip
      ENV["DYLD_FALLBACK_LIBRARY_PATH"] = "#{xcode_path}/usr/lib/"
    end
    # 步骤 1: 编译 Rust 应用
    system "cargo", "build", "--release", "--bin", executable_name

    # 步骤 2: 创建标准的 .app 文件夹结构
    # 我们直接在 Homebrew 的安装目录里创建这个 .app 包
    app_path = prefix/"#{app_name}.app"
    macos_path = app_path/"Contents/MacOS"
    resources_path = app_path/"Contents/Resources"

    macos_path.mkpath
    resources_path.mkpath

    # 步骤 3: 将编译好的程序放进 .app 包里
    macos_path.install "target/release/#{executable_name}"

    # (新增) 步骤 4: 复制图标文件
    # 请确保您的项目源码的根目录有一个名为 assets 的文件夹，
    # 并且里面包含一个 icon.icns 文件。
    if File.exist?("icons/icon.icns")
      resources_path.install "icons/icon.icns"
    end

    # 步骤 5: 创建 Info.plist 配置文件
    # 这个文件告诉 macOS 应用的基本信息，比如名称、图标和需要的权限
    info_plist_path = app_path/"Contents/Info.plist"
    info_plist_path.write <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>CFBundleExecutable</key>
        <string>#{executable_name}</string>
        <key>CFBundleIconFile</key>
        <string>icon.icns</string>
        <key>CFBundleIdentifier</key>
        <string>com.github.Your-GitHub-Username.#{app_name.downcase}</string>
        <key>CFBundleName</key>
        <string>#{app_name}</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleShortVersionString</key>
        <string>#{version}</string>
        <key>CFBundleVersion</key>
        <string>#{version}</string>
        <key>NSHighResolutionCapable</key>
        <true/>
        <key>NSCameraUsageDescription</key>
        <string>#{camera_usage_description}</string>
      </dict>
      </plist>
    EOS
  end
  Pathname.new("target").rmtree
  ln_sf prefix/"#{app_name}.app", "/Applications/#{app_name}.app"
  # --- (4) 安装后提示 ---
  # 这是最重要的部分，它会在安装成功后显示给用户，告诉他们下一步该怎么做。
  def caveats
    <<~EOS
      🎉 Polarimeter 安装完成！

      您现在可以在“应用程序”(Applications)文件夹中找到它。
      也可以通过“启动台”(Launchpad)来打开它，就像其他普通应用一样。
    EOS
  end

  # --- (5) 测试 ---
  test do
    # 检查 .app 包是否被成功创建
    assert_predicate prefix/"Polarimeter.app", :exist?
  end
end


