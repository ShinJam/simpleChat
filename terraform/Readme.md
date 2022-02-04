# simpleChat Provisioning

# Notes

## go-json memory issue

jenkins 인스턴스에서 go build가 안되는 문제 발견
```shell
go build github.com/goccy/go-json: /usr/local/go/pkg/tool/linux_amd64/compile: signal: killed
```
찾아보니 go-json이 빠른대신에 메모리를 좀 차지 한다고 한다.
t2.micro에서 t2.small로 변경하여 해결한다.

<details>
    <summary>Reference</summary>

- [Can't build package: "signal: killed"](https://github.com/blevesearch/segment/issues/5)

</details>


## Jenkins ALB Health check

```text
Health checks failed with these code: [403]
```
bastion으로 jenkins 인스턴스에 들어가 jenkins 켜저 있는 것을 확인
```shell
$ netstat -nlp | grep 8080
```
- 원인: 로그인 하지 않아서 jenkins에서 403 반환했기 때문
- 해결방법: health path를 /에서 /login으로 변경


## Security Group 이 안지워는 문제

```shell
DependencyViolation: resource sg-12345678 has a dependent object
        status code: 400, request id: abcdefg-dead-beef-dead-abcdefg123456
```
terraform은 sg가 아직 instance와 관련이 있을 때 삭제 시키지 않는다. instance를 먼저 지워야 하는데 ALB랑 물려서 삭제 되지 않는 것으로 보인다.
근본적으로 terraform은 양방향 디펜턴를 지원하지 않는다. 따라서 근본적인 해결 방법은 없지만 아래와 같은 방법이 방편이 된다.

- 해결방법: create_before_destroy 추가
  create_before_destroy=true는 냅다 지우는 것이 아닌 지우기전에 새로운 리소스를 생성하고 지우게 한다는일옵션
  ```terraform
  resource "aws_security_group" "ex" {
    name   = "some sg"
    vpc_id = var.vpc_id

    lifecycle {
      create_before_destroy = true
    }
  }
  ```
  `terraform-aws-security-group`모듈을 사용하고 있기 때문에 use_name_prefix=true 를 해줘야 했다.

<details>
    <summary>Reference</summary>

- [AWS security groups not being destroyed #2445](https://github.com/hashicorp/terraform-provider-aws/issues/2445)
- https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/main.tf#L36

</details>


# Tips
## AWS resource 전체 삭제
- install [cloud-nuke](https://github.com/gruntwork-io/cloud-nuke)
```shell
$ brew install clude-nuke
```
- Excuetion
```shell
$ cloud-nuke aws --region ap-northeast-2 --exclude-resource-type iam
```

## curl status code 확인

```shell
$ curl -w " - status code: %{http_code}" http://localhost:8080
```

<details>
    <summary>Reference</summary>

- [[Shell] curl로 호출하고 HTTP status code 확인하기](https://blog.leocat.kr/notes/2018/08/03/shell-fetch-http-status-code-from-curl-result)

</details>

## instance 초기화
인스턴스 생성후 패키지 설정등 초기화 방법에는 세가지 방법이 있다.
1. Ansible
2. run script
3. [cloud-init](https://cloudinit.readthedocs.io/en/latest/)

2번 방법을 사용하기위해 script를 만들고 [user_data](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)에 넘겨줬다.

<details>
    <summary>Reference</summary>

- [How to pass multiple template files to user_Data variable in terraform](https://stackoverflow.com/a/62070854/12364975)
- [terraform copy/upload files to aws ec2 instance](https://stackoverflow.com/a/62105461/12364975)
- [Terraform Ansible Integration | Terraform Ansible AWS Example](https://www.youtube.com/watch?v=QxgJlJgGA0E&t=100s)
- [Getting Started with cloud-init](https://www.youtube.com/watch?v=exeuvgPxd-E)

</details>

### ssh tunneling

```shell
$ ssh -nNT -L {LCOAL_PORT}:{RDS_ENDPOINT}:{REMOTE_PORT} {HOSTNAME}
```

<details>
    <summary>Reference</summary>

- [SSH setup and tunneling via Bastion host](https://dev.to/aws-builders/ssh-setup-and-tunneling-via-bastion-host-3kcc)

</details>

### api 요청만 접근 가능하게 하는 SG
sg의 Source를 다른 sg를 갖는다면 그 sg을갖고 있는 요청만 받을 수 있다.

<details>
    <summary>Reference</summary>

- [(AWS) Security Group에서 다른 Security Group을 참조하는 경우](https://perfectacle.github.io/2018/08/30/aws-security-group-reference-another-security-group/)
- [Terraform으로 AWS Security Group 설정하기](https://rampart81.github.io/post/security_group_terraform/)

</details>

### Permission denied (publickey).
ssh 접근시 denied 됐을 때 여러가지 이유가 있을 수 있지만 authorized_keys가 삭제돼 문제 발생.
삭제된 이유로는 cloudinit 사용하면서 발생
- 해결 방법1: 임으로 authorized_keys 추가

<details>
    <summary>Reference</summary>

- [[AWS] EC2 접속용 SSH 키페어 분실 또는 손상 시 키 재생성 방법](http://blog.freezner.com/archives/2303)
- [AWS EC2 authorized_key 삭제 문제 로 인한 접속 불가 해결](https://knphouse.tistory.com/102)
- [EC2 keypair works in one instance but fails on other - Permission denied (publickey)](https://stackoverflow.com/questions/23068591/ec2-keypair-works-in-one-instance-but-fails-on-other-permission-denied-public)
- [접속이 잘 되던 KeyPair가 갑자기 Permission Denied 된다](https://nara.dev/til/aws/sudden-accessdenied.html#%E1%84%8B%E1%85%B3%E1%86%BC%E1%84%80%E1%85%B3%E1%86%B8-%E1%84%8C%E1%85%A9%E1%84%8E%E1%85%B5-immediate-action)

</details>
