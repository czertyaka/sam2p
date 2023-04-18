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
        stage("Fuzzing") {
            agent {
                docker {
                    image "aflplusplus/aflplusplus"
                }
            }
            environment {
                AFL_USE_ASAN = 1
                AFL_USE_UBSAN = 1
                AFL_USE_CFISAN = 1
                AFL_USE_LSAN = 1
            }
            steps {
                sh "CC=afl-cc CXX=afl-c++ ./configure --enable-debug=yes"
                sh "make -j \$(nproc)"
            }
        }
    }
}
