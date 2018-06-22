FROM jcberthon/baseline:latest as baseline
FROM jcberthon/level1:latest as level1
FROM jcberthon/level2:latest

COPY --from=baseline /project/test/bug.txt /project/test/bug.txt
COPY --from=level1 /project/test/hello.txt /project/test/hello.txt

ENTRYPOINT [ "bash", "-c", "cat /project/test/hello.txt | /usr/games/cowsay" ]
