commit:
	git add -A
#	git commit -m "$(curl -s http://whatthecommit.com/index.txt)"
	git commit -m "Associate Route Table with subnets"
	git push -u origin main

get-commit:
	curl -s http://whatthecommit.com/index.txt