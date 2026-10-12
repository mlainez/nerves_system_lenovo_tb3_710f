# The TB3-710F board packages (packages/mt8127-*, packages/tb3-*) take their
# sources from Spin42/buildroot-android, where the Buildroot port of this
# tablet lives, at a pinned commit. One tarball serves them all: each package
# extracts only its own directory (TB3_BRA_EXTRACT). To build from a local
# checkout instead, see local.mk.example.
TB3_BRA_VERSION = 9b797a3cfbb3e64363c13573face827847df0d65
TB3_BRA_SITE = $(call github,Spin42,buildroot-android,$(TB3_BRA_VERSION))
TB3_BRA_SOURCE = buildroot-android-$(TB3_BRA_VERSION).tar.gz
TB3_BRA_DL_SUBDIR = tb3-buildroot-android

# $(1): package variable prefix, $(2): directory inside the repository.
# Extracts that directory's contents into the package build directory.
define TB3_BRA_EXTRACT
	$(call suitable-extractor,$($(1)_SOURCE)) $($(1)_DL_DIR)/$($(1)_SOURCE) | \
		$(TAR) -x -C $(@D) --strip-components=$(words $(subst /, ,$(2)) x) \
			--wildcards '*/$(2)/*' $(TAR_OPTIONS) -
endef

include $(sort $(wildcard $(NERVES_DEFCONFIG_DIR)/packages/*/*.mk))
