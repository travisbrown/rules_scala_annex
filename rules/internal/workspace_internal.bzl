load(":internal/utils.bzl", utils = "root")

def _entry(ctx, prefix, raw_version):

    organization, version = raw_version.split(':')
    saniorganization = utils.safe_name(organization)
    saniversion = utils.safe_name(version)

    name = '%s_%s' % (prefix, version.replace('.', '_'))
    binary_version = '_'.join(version.split('.')[0:2])

    compiler_bridge = ctx.attr.compiler_bridge_label_pattern[prefix].format(binary_version = binary_version)
    compiler_bridge_classpath = '[]'

    return utils.strip_margin("""
      |#
      |# prefix : {prefix}
      |# version: {raw_version}
      |#
      |annex_configure_scala(
      |    name = '{name}',
      |    version = '{version}',
      |    binary_version = '{binary_version}',
      |    compiler_classpath = [
      |        '@{saniorganization}_scala_compiler_{saniversion}//jar',
      |        '@{saniorganization}_scala_reflect_{saniversion}//jar',
      |        '@{saniorganization}_scala_library_{saniversion}//jar',
      |    ],
      |    compiler_bridge = '{compiler_bridge}',
      |    compiler_bridge_classpath = [
      |        '@compiler_interface//jar',
      |        '@util_interface//jar',
      |    ],
      |    runtime_classpath = [
      |        '@{saniorganization}_scala_library_{saniversion}//jar',
      |    ],
      |    visibility = ["//visibility:public"],
      |)
    """.format(
        prefix = prefix,
        raw_version = raw_version,
        version = version,
        binary_version = binary_version,
        name = name,
        compiler_bridge = compiler_bridge,
        saniversion = saniversion,
        saniorganization = saniorganization
    ))

def annex_configure_scala_repository_implementation(ctx):
    entries = []
    for prefix, raw_versions in ctx.attr.versions.items():
        for raw_version in raw_versions:
            entries.append(_entry(ctx, prefix, raw_version))

    preamble = utils.strip_margin("""
      |#
      |# generated by scala annex
      |#
      |
      |load("@scala_annex//rules:build.bzl", "annex_configure_scala")
      |
      |""")

    build_contents = preamble + "\n".join(entries)
    ctx.file("BUILD", build_contents, False)
