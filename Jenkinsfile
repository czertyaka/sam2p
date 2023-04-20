pipeline {
    agent none
    stages {
        stage("Build") {
            agent {
                dockerfile {
                    filename "ci/gcc.Dockerfile"
                }
            }
            stages {
                stage("Release") {
                    steps {
                        sh "cmake -B /root/build/Release ."
                        sh "cmake --build /root/build/Release --target sam2p -j \$(nproc)"
                    }
                }
                stage("Debug") {
                    steps {
                        sh "cmake -B /root/build/Debug . -DCMAKE_BUILD_TYPE=Debug"
                        sh "cmake --build /root/build/Debug --target sam2p -j \$(nproc)"
                    }
                }
                stage("Tests") {
                    steps {
                        dir("/root/build/Debug") {
                            sh "ctest --output-on-failure"
                            sh "mkdir -p coverage"
                            sh "lcov -t 'sam2p' -c -d CMakeFiles/sam2p.dir/ -o coverage/sam2p.info"
                            sh "genhtml -o coverage/report coverage/sam2p.info"
                        }
                    }
                    post {
                        success {
                            publishHTML(
                                target: [
                                    allowMissing: false,
                                    alwaysLinkToLastBuild: true,
                                    keepAll: false,
                                    reportDir: "build/Debug/coverage/report",
                                    reportFiles: "index.html",
                                    reportName: "Tests Coverage Report"
                                ]
                            )
                        }
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
            }
            steps {
                sh "cmake -B /root/build/Fuzzing . -DCMAKE_CXX_COMPILER=afl-g++"
                dir("/root/build/Fuzzing") {
                    sh "cmake --build . --target sam2p -j \$(nproc)"
                    sh "ctest"
                }
            }
        }
    }
}
