PWD="$(shell pwd)"

# Change this to your video's location.
VIDEO="$(PWD)/wallpaper/wallpaper.mp4"

# xwinwrap repo location
REPO="https://github.com/mmhobi7/xwinwrap.git"

# --------------------------------
# Animated wallpaper
# --------------------------------

.PHONY: wallpaper get-xwinwrap

get-xwinwrap:
	mkdir -p ext
	if [ ! -d ext/xwinwrap ]; then git clone $(REPO) ext/xwinwrap; fi
	@echo "Go to ext/xwinwrap, run make, sudo make install, make clean."
	@echo "https://github.com/mmhobi7/xwinwrap"

wallpaper:
	echo $(VIDEO)
	./startup.sh $(VIDEO)

# -----------------------------
# Examples for vidtools.sh
# -----------------------------

.PHONY: example-info

example-info:
	./vidtools.sh info example/frieren-water.mp4

example-trim:
	./vidtools.sh trim example/frieren-water.mp4 1 1

example-loop: example/frieren-water-trim.mp4
	./vidtools.sh loop example/frieren-water-trim.mp4

example/frieren-water-trim.mp4: example-trim
