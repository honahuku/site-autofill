# site-autofill
## command
docker build . -f ./DockerFile -t site-autofill:7 --build-arg ACCOUNT_PW='aaa' --build-arg EMAIL='bbb' --build-arg MFA_KEY='ccc' --build-arg URL='ddd'
docker run -d -it --name test7.7 site-autofill:7