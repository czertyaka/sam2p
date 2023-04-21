pipeline {
    agent none
    parameters {
        string(
            name: 'FUZZING_TIMEOUT',
            defaultValue: '30m'
        )
    }
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
                        sh "cmake -B build/Release ."
                        sh "cmake --build build/Release --target sam2p -j \$(nproc)"
                    }
                }
                stage("Debug") {
                    steps {
                        sh "cmake -B build/Debug . -DCMAKE_BUILD_TYPE=Debug"
                        sh "cmake --build build/Debug --target sam2p -j \$(nproc)"
                    }
                }
                stage("Tests") {
                    steps {
                        dir("build/Debug") {
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
            post {
                always {
                    cleanWs(deleteDirs: true)
                }
            }
        }
        stage("Fuzzing") {
            agent {
                dockerfile {
                    filename "ci/afl.Dockerfile"
                }
            }
            stages {
                stage("Prepare") {
                    environment {
                        AFL_USE_ASAN = 1
                        AFL_LLVM_LAF_ALL = 1
                    }
                    steps {
                        sh """
                            cmake -B build/Fuzzing . \
                                -DCMAKE_CXX_COMPILER=afl-clang-lto++ \
                                -DCMAKE_LINKER=afl-clang-lto \
                                -DCMAKE_AR=llvm-ar-14 \
                                -DCMAKE_CXX_COMPILER_RANLIB=llvm-ranlib-14
                        """
                        sh "cmake --build build/Fuzzing --target sam2p -j \$(nproc)"
                        sh "mkdir -p build/Fuzzing/corpus"
                        sh "cp examples/*.pbm build/Fuzzing/corpus"
                        sh "cp examples/*.bmp build/Fuzzing/corpus"
                    }
                }
                stage("Run") {
                    parallel {
                        stage("PDF") {
                            steps {
                                sh "./ci/run_fuzzer.sh 'build/Fuzzing' '${params.FUZZING_TIMEOUT}' 'pdf' '1'"
                            }
                        }
                        stage("PNG") {
                            steps {
                                sh "./ci/run_fuzzer.sh 'build/Fuzzing' '${params.FUZZING_TIMEOUT}' 'png' '0'"
                            }
                        }
                        stage("TIFF") {
                            steps {
                                sh "./ci/run_fuzzer.sh 'build/Fuzzing' '${params.FUZZING_TIMEOUT}' 'tiff' '0'"
                            }
                        }
                        stage("EPS") {
                            steps {
                                sh "./ci/run_fuzzer.sh 'build/Fuzzing' '${params.FUZZING_TIMEOUT}' 'eps' '0'"
                            }
                        }
                    }
                }
            }
            post {
                always {
                    cleanWs(
                        deleteDirs: true,
                        patterns: [
                            [ pattern: "build/corpus/*", type: 'EXCLUDE' ],
                            [ pattern: "build/output/*", type: 'EXCLUDE' ]
                        ]
                    )
                }
            }
        }
    }
}
