// #define _GNU_SOURCE

#include <dlfcn.h>
#include <stdio.h>
#include <iostream>


class Player {
  
  

  public:
    char padding[736];
    float speed;
    float jumpspeed;
    float jumphold;
    void Chat(const char *text);

};


struct Vector3 { float x; float y; float z; };

typedef void (*orig_chat_f_type)(Player *, const char *);
typedef void (*orig_teleport_f_type)(Player *, const std::string);
typedef void (*orig_player_f_type)(Player *, bool isAdmin);
typedef void (*orig_fast_travel_f_type)(Player *, const std::string, const std::string);
typedef void (*orig_respawn_f_type)(Player *);
typedef void (*orig_get_fast_travel_f_type)(Player *, const char *);
typedef void (*orig_pos_f_type)(Player *, const Vector3 *);



void Player::Chat(const char *text)
{

  std::string str(text);

  if (str.compare(0, 3, "tp ") == 0)
  {

    bool teleport = true;
    Vector3 pos;
    str.erase(0, 3);

    if (!str.compare("GreatBallsOfFire")) {
      pos.x =  -43655.0;
      pos.y =  -56210.0;
      pos.z =     471.0;
    } else if (!str.compare("MichaelAngelo")) {
      pos.x =  260255.0;
      pos.y = -249336.0;
      pos.z =    1476.0;
    } else if (!str.compare("Town")) {
      pos.x =  -39130.0;
      pos.y =  -20280.0;
      pos.z =    2530.0;
    } else if (!str.compare("BearChestTop")) {
      pos.x =   -7894.0;
      pos.y =   64482.0;
      pos.z =    5663.0;
    } else if (!str.compare("BearChestUnder")) {
      pos.x =   -7894.0;
      pos.y =   64482.0;
      pos.z =    2663.0 - 244.0;
    } else if (!str.compare("BallmerPeak")) {
      pos.x =   -6791.0;
      pos.y =  -11655.0;
      pos.z =   10528.0;
    } else if (!str.compare("LavaCave")) {
      pos.x =   50876.0;
      pos.y =   -5243.0;
      pos.z =    1645.0;
    } else if (!str.compare("BlockyCave")) {
      pos.x =  -18450.0;
      pos.y =   -4360.0;
      pos.z =    2225.0;
    } else if (!str.compare("GoldFarm")) {
      pos.x =   21162.0;
      pos.y =   41232.0;
      pos.z =    2256.0;
    } else if (!str.compare("PirateChest")) {
      pos.x =   45774.0;
      pos.y =   58794.0;
      pos.z =     671.0;
    } else {
      teleport = false;
      std::cout << "Teleport: Wrong location!\n";
    }
    
    if (teleport)
    {
      std::cout << "Teleport: " << str << "\n";
  
      const Vector3 p = pos;
      orig_pos_f_type orig;
      orig = (orig_pos_f_type) dlsym(RTLD_NEXT, "_ZN5Actor11SetPositionERK7Vector3");
      orig(this, &p);
    }
  }
  else if (str.compare(0, 3, "ft ") == 0)
  {
    str.erase(0, 3);
    int pos = str.find(" ");
    const std::string origin = str.substr(0, pos);
    str.erase(0, pos+1);
    const std::string dest = str;
    
    std::cout << "Fast Travel: " << dest << "\n";
    orig_fast_travel_f_type orig;
    orig = (orig_fast_travel_f_type) dlsym(RTLD_NEXT, "_ZN6Player17PerformFastTravelERKSsS1_");
    orig(this, origin, dest);
  }
  else if (str.compare(0, 3, "sp ") == 0)
  {
    str.erase(0, 3);
    if (str.compare("up") == 0)
      this->speed = this->speed * 4;
    else if (str.compare("down") == 0)
      this->speed = this->speed / 4;
    else
      std::cout << "Usage: sp <up|down>\n";
  }
  else if (str.compare(0, 3, "jp ") == 0)
  {
    str.erase(0, 3);
    if (str.compare("up") == 0)
      this->jumpspeed = this->jumpspeed * 1.5;
    else if (str.compare("down") == 0)
      this->jumpspeed = this->jumpspeed / 1.5;
    else
      std::cout << "Usage: sp <up|down>\n";
  }
  else
  {
    orig_chat_f_type orig;
    orig = (orig_chat_f_type) dlsym(RTLD_NEXT, "_ZN6Player4ChatEPKc");
    orig(this, "Command not identified.");
    orig(this, "Type \"help\" for more information.");
  }

  // Call orignal Player::Chat() function
  orig_chat_f_type orig;
  orig = (orig_chat_f_type) dlsym(RTLD_NEXT, "_ZN6Player4ChatEPKc");
  orig(this, text);

}

