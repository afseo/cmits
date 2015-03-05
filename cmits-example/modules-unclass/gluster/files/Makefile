TEs = $(wildcard *.te)
PPs = $(addsuffix .pp,$(basename $(TEs)))

all: $(PPs)

# Puppet files end with .pp, and so do SELinux policy packages. The
# unified-policy-document has some magic in its Makefile that finds all *.pp
# files, and we don't want it to try to treat these as Puppet files, so inside
# the policy we call them *.selinux.pp.

clean:
	rm -f *.selinux.pp *.mod

%.pp: %.mod
	semodule_package -m $< -o $@
	mv $@ $(addsuffix .selinux.pp,$(basename $@))

%.mod: %.te
	checkmodule -M -m $< -o $@

