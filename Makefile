prune:
	git checkout develop && git pull origin develop && git fetch -p && git branch --merged | egrep -v "(^\*|master|develop)" | xargs git branch -d
