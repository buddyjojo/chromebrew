require 'package'

class Jdk17 < Package
  description 'The JDK is a development environment for building applications, applets, and components using the Java programming language.'
  homepage 'https://www.oracle.com/java/technologies/downloads/#java17'
  version '17.0.3'
  license 'Oracle-BCLA-JavaSE'
  compatibility 'x86_64'
  source_url 'SKIP'

  binary_url ({
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/jdk17/17.0.3_x86_64/jdk17-17.0.3-chromeos-x86_64.tar.zst',
  })
  binary_sha256 ({
     x86_64: '650fc2e027e3625d93d8350f2dcff472dbbaa26e5886c1b98a1edf25360db946',
  })

  no_patchelf

  def self.preflight
    abort "JDK8 installed.".lightgreen if Dir.exist? "#{CREW_PREFIX}/share/jdk8"
    abort "JDK11 installed.".lightgreen if Dir.exist? "#{CREW_PREFIX}/share/jdk11"
    abort "JDK15 installed.".lightgreen if Dir.exist? "#{CREW_PREFIX}/share/jdk15"
    abort "JDK16 installed.".lightgreen if Dir.exist? "#{CREW_PREFIX}/share/jdk16"
    abort "JDK18 installed.".lightgreen if Dir.exist? "#{CREW_PREFIX}/share/jdk18"
  end

  def self.install
    jdk_bin = "#{HOME}/Downloads/jdk-17_linux-x64_bin.tar.gz"
    jdk_sha256 = '67b390651dea7223b684a2003c4bd630f3ab915033c26c2237367c1da2fa91c5'
    unless File.exist? jdk_bin then
      puts
      puts "Oracle now requires an account to download the JDK.".orange
      puts
      puts "You must login at https://login.oracle.com/mysso/signon.jsp and then visit:".orange
      puts "https://www.oracle.com/java/technologies/downloads/#java17".orange
      puts
      puts "Download the JDK for your architecture to #{HOME}/Downloads to continue.".orange
      puts
      abort
    end
    abort 'Checksum mismatch. :/ Try again.'.lightred unless Digest::SHA256.hexdigest( File.read(jdk_bin) ) == jdk_sha256
    system "tar xvf #{jdk_bin}"
    jdk17_dir = "#{CREW_DEST_PREFIX}/share/jdk17"
    FileUtils.mkdir_p "#{jdk17_dir}"
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/bin"
    FileUtils.cd "jdk-#{version}" do
      FileUtils.rm_f 'lib/src.zip'
      FileUtils.mv Dir['*'], "#{jdk17_dir}/"
    end
    Dir["#{jdk17_dir}/bin/*"].each do |filename|
      binary = File.basename(filename)
      FileUtils.ln_s "#{CREW_PREFIX}/share/jdk17/bin/#{binary}", "#{CREW_DEST_PREFIX}/bin/#{binary}"
    end
    FileUtils.rm ["#{jdk17_dir}/man/man1/kinit.1", "#{jdk17_dir}/man/man1/klist.1"] # conflicts with krb5 package
    FileUtils.mv "#{jdk17_dir}/man/", "#{CREW_DEST_PREFIX}/share/"
  end
end
