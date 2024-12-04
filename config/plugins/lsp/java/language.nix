{
  lib,
  pkgs,
  ...
}: let
  #lombokBIN = lib.getBin pkgs.lombok;
  #lombokJAR = "${lombokBIN}/share/java/lombok.jar";
  lombok = "/home/winder/.local/share/nvim/mason/share/jdtls/lombok.jar";
  javaExe = lib.getExe pkgs.jdk21;
  #jdtlsBIN = lib.getBin pkgs.jdt-language-server;
  #jdtlsExe = lib.getExe pkgs.jdt-language-server;
  #jdtlsJAR = "${jdtlsBIN}/share/java/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar";
  jdtlsJAR = "/home/winder/.local/share/nvim/mason/share/jdtls/plugins/org.eclipse.equinox.launcher.jar";
  #jdtlsCon = "${jdtlsBIN}/share/java/jdtls/config_linux/config.ini";
  jdtlsCon = "/home/winder/.local/share/nvim/mason/packages/jdtls/config_linux";
  #javaDebugAdapterBIN = lib.getBin pkgs.vscode-extensions.vscjava.vscode-java-debug;
  #javaDebugAdapterJAR = "${javaDebugAdapterBIN}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-0.50.0.jar";
  workspaceDIR = "/home/winder/.cache/jdtls/config";
in {
  plugins = {
    nvim-jdtls = {
      enable = true;
      cmd = [
        "${javaExe}"
        "-Declipse.application=org.eclipse.jdt.ls.core.id1"
        "-Dosgi.bundles.defaultStartLevel=4"
        "-Declipse.product=org.eclipse.jdt.ls.core.product"
        "-Djava.util.prefs.userRoot=/home/winder/.config/java"
        "-Dlog.protocol=true"
        "-Dlog.level=ALL"
        "-javaagent:${lombok}"
        "-Xmx4g"
        "--add-modules=ALL-SYSTEM"
        "--add-opens"
        "java.base/java.util=ALL-UNNAMED"
        "--add-opens"
        "java.base/java.lang=ALL-UNNAMED"
        "-jar"
        "${jdtlsJAR}"
        "-configuration"
        "${jdtlsCon}"
        "-data"
        "${workspaceDIR}"
      ];
      rootDir = {
        __raw = "vim.fs.dirname(vim.fs.find({'gradlew', '.git', 'mvnw'}, { upward = true })[1])";
      };
      settings = {
        java = {
          # TODO Replace this with the absolute path to your main java version (JDK 17 or higher)
          home = "${javaExe}";
          eclipse = {
            downloadSources = true;
          };
          maven = {
            downloadSources = true;
          };
          implementationsCodeLens = {
            enabled = true;
          };
          referencesCodeLens = {
            enabled = true;
          };
          references = {
            includeDecompiledSources = true;
          };
          signatureHelp = {
            enabled = true;
          };
          format = {
            enabled = true;
          };
        };
        completion = {
          favoriteStaticMembers = [
            "org.hamcrest.MatcherAssert.assertThat"
            "org.hamcrest.Matchers.*"
            "org.hamcrest.CoreMatchers.*"
            "org.junit.jupiter.api.Assertions.*"
            "java.util.Objects.requireNonNull"
            "java.util.Objects.requireNonNullElse"
            "org.mockito.Mockito.*"
          ];
          importOrder = [
            "java"
            "javax"
            "com"
            "org"
          ];
        };
        extendedClientCapabilities.__raw = "require('jdtls').extendedClientCapabilities";
        sources = {
          organizeImports = {
            starThreshold = 9999;
            staticStarThreshold = 9999;
          };
        };
        #codeGeneration = {
        #	toString = {
        #		template.__raw = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}";
        #	};
        #	useBlocks = true;
        #};
      };
    };
  };
}
