FROM docker.io/jenkins/jenkins

RUN jenkins-plugin-cli --plugins configuration-as-code ldap role-strategy pipeline-model-definition pipeline-stage-view \
    github-branch-source build-timeout embeddable-build-status rebuild ws-cleanup authorize-project

