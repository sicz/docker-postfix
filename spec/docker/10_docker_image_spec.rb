require "docker_helper"

### DOCKER_IMAGE ###############################################################

describe "Docker image", :test => :docker_image do
  # Default Serverspec backend
  before(:each) { set :backend, :docker }

  ### DOCKER_IMAGE #############################################################

  describe docker_image(ENV["DOCKER_IMAGE"]) do
    # Execute Serverspec command locally
    before(:each) { set :backend, :exec }
    it { is_expected.to exist }
  end

  ### PACKAGES #################################################################

  describe "Packages" do
    [
      # [package,                   version,                    installer]
      "make",
      ["postfix",                   ENV["POSTFIX_VERSION"]],
      "rsyslog",
    ].each do |package, version, installer|
      describe package(package) do
        it { is_expected.to be_installed }                        if installer.nil? && version.nil?
        it { is_expected.to be_installed.with_version(version) }  if installer.nil? && ! version.nil?
        it { is_expected.to be_installed.by(installer) }          if ! installer.nil? && version.nil?
        it { is_expected.to be_installed.by(installer).with_version(version) } if ! installer.nil? && ! version.nil?
      end
    end
  end

  ### FILES ####################################################################

  describe "Files" do
    [
      # [
      #   file,
      #   mode, user,       group,      [expectations],
      #   match
      # ]
      [
        "/docker-entrypoint.sh",
        755, "root",      "root",     [:be_file],
      ], [
        "/docker-entrypoint.d/31-postfix-environment.sh",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/docker-entrypoint.d/47-postfix-certs.sh",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/docker-entrypoint.d/50-postfix-settings.sh",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/docker-entrypoint.d/80-postfix-update.sh",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/periodic/daily/postfix-reload",
        755, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/postfix/aliases",
        644, "root",      "root",     [:be_file],
        "^root:\s+root@example.com$",
      ], [
        "/etc/postfix/host_access.cidr",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/postfix/main.cf",
        644, "root",      "root",     [:be_file],
        [
          "^myhostname = host.example.com$",
          "^mydomain = example.com$",
          "^relayhost = \\[relay.example.com\\]$",
          "^smtp_dns_support_level = dnssec$",
          "^message_size_limit = 1000000$",
          "^smtp_use_tls = yes$",
          "^smtpd_use_tls = yes$",
          "^smtpd_milters = inet:rspamd.local:11332$"
        ],
      ], [
        "/etc/postfix/master.cf",
        644, "root",      "root",     [:be_file],
        [
          "^#smtp .* smtpd",
          "^smtp .* postscreen",
          "^smtpd .* smtpd",
        ],
      ], [
        "/etc/postfix/Makefile",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/postfix/mynetworks",
        644, "root",      "root",     [:be_file],
        "^192.0.2.0/24$",
      ], [
        "/etc/postfix/recipient_access",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/postfix/relay_domains",
        644, "root",      "root",     [:be_file],
        [
          "^example.com RELAY$",
          "^\\.example.com RELAY$",
        ],
      ], [
        "/etc/postfix/sasl_passwd",
        644, "root",      "root",     [:be_file],
        "^relay.example.com relay:P@ssw0rd."
      ], [
        "/etc/postfix/sender_access",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/postfix/transport",
        644, "root",      "root",     [:be_file],
        [
          "^example.com relay:\\[relay.example.com\\]",
          "^\\.example.com relay:\\[relay.example.com\\]",
        ],
      ], [
        "/etc/rsyslog.conf",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/rsyslog.d/postfix.conf",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/supervisor/conf.d/postfix.ini",
        644, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/etc/supervisor/wrapper/postfix",
        755, "root",      "root",     [:be_file, :eq_sha256sum],
      ], [
        "/var/spool/postfix",
        2755, "postfix",  "postfix",   [:be_directory],
      ],
    ].each do |file, mode, user, group, expectations, matches|
      expectations ||= []
      context file(file) do
        it { is_expected.to exist }
        it { is_expected.to be_file }       if expectations.include?(:be_file)
        it { is_expected.to be_socket }     if expectations.include?(:be_socket)
        it { is_expected.to be_directory }  if expectations.include?(:be_directory)
        it { is_expected.to be_mode(mode) } unless mode.nil?
        it { is_expected.to be_owned_by(user) } unless user.nil?
        it { is_expected.to be_grouped_into(group) } unless group.nil?
        its(:sha256sum) do
          is_expected.to eq(
              Digest::SHA256.file("rootfs/#{subject.name}").to_s
          )
        end if expectations.include?(:eq_sha256sum)
        Array(matches).each do |match|
          its(:content) { is_expected.to match(match) }
        end
      end
    end
  end

  ##############################################################################

end

################################################################################
