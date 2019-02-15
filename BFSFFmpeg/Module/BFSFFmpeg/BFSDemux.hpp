//
//  BFSDemux.hpp
//  BFSFFmpeg
//
//  Created by 刘玲 on 2019/2/15.
//  Copyright © 2019年 Alex BF. All rights reserved.
//

#ifndef BFSDemux_hpp
#define BFSDemux_hpp

#include <stdio.h>

class BFSDemux
{
    public:
    BFSDemux();
    
    void demuxAVAtLocalPath(const char *path);
};

#endif /* BFSDemux_hpp */
