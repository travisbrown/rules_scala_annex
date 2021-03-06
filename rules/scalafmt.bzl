load(
    "//rules/scalafmt:private/test.bzl",
    _annex_scala_format_test_implementation =
        "annex_scala_format_test_implementation",
    _annex_scala_format_private_attributes =
        "annex_scala_format_private_attributes",
)

annex_scala_format_test = rule(
    implementation = _annex_scala_format_test_implementation,
    attrs = dict({
        "config": attr.label(
            allow_single_file = [".conf"],
            default = "@scalafmt_default//:config",
        ),
        "srcs": attr.label_list(
            allow_files = [".scala"],
        ),
    }, **_annex_scala_format_private_attributes),
    test = True,
    outputs = {
        "runner": "%{name}-format",
    },
)
