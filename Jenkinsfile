pipeline {
    agent none
    stages {
        stage("Build") {
            agent {
                docker {
                    image "gcc:latest"
                }
            }
            stages {
                stage("Release") {
                    steps {
                        sh "make clean"
                        sh "./configure --enable-debug=no"
                        sh "make -j \$(nproc)"
                    }
                }
                stage("Debug") {
                    steps {
                        sh "make clean"
                        sh "./configure --enable-debug=yes"
                        sh "make -j \$(nproc)"
                    }
                }
            }
        }
    }
}
