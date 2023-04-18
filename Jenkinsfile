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
                        sh '''
                            make -j $(nproc) \
                                CXXFLAGS="-Os -finline-functions -DHAVE_CONFIG2_H -fsigned-char -fno-rtti -fno-exceptions"
                        '''
                    }
                }
            }
        }
    }
}
