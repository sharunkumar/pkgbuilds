update-srcinfo:
	@for dir in */ ; do \
		if [ -d "$$dir" ]; then \
			cd "$$dir" && \
			makepkg --printsrcinfo > .SRCINFO && \
			cd .. ; \
		fi \
	done