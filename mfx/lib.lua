local sys_stat = require "posix.sys.stat"
local inspect = require "inspect"
local socket  = require "socket"
local ffi = require "ffi"

ffi.cdef[[
size_t strlen (const char*);
void * memmove( void * destination, const void * source, size_t size );
void * memcpy( void * destination, const void * source, size_t size );
void * memset( void * destination, int value, size_t size );
typedef void lua_DspFaust;
typedef float FAUSTFLOAT;
typedef void* Soundfile;
typedef struct {
  void (*openTabBox)(const char* label);
  void (*openHorizontalBox)(const char* label);
  void (*openVerticalBox)(const char* label);
  void (*closeBox)();
  void (*addButton)(const char* label, FAUSTFLOAT* zone);
  void (*addCheckButton)(const char* label, FAUSTFLOAT* zone);
  void (*addVerticalSlider)(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step);
  void (*addHorizontalSlider)(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step);
  void (*addNumEntry)(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT init, FAUSTFLOAT min, FAUSTFLOAT max, FAUSTFLOAT step);
  void (*addHorizontalBargraph)(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max);
  void (*addVerticalBargraph)(const char* label, FAUSTFLOAT* zone, FAUSTFLOAT min, FAUSTFLOAT max);
  void (*addSoundfile)(const char* label, const char* soundpath, Soundfile** sf_zone);
  void (*declare)(FAUSTFLOAT* zone, const char* key, const char* val);  
} CLuaUI;
lua_DspFaust* lua_newDspfaust(const char * file, char * error_msg, int sample_rate, int buffer_size, int argc, const char* argv[]);
void lua_startDspfaust(lua_DspFaust* dsp);
void lua_stopDspfaust(lua_DspFaust* dsp);
void lua_buildCLuaInterface(lua_DspFaust* dsp, CLuaUI* lua_struct);
float* lua_getDspMemory(lua_DspFaust* dsp);
struct rb_compute_buffers {
  uint8_t channels;
  uint16_t nframes;
  float buffers[16][2048];
};
typedef struct {
  char *buf;
  size_t len;
}
mfx_ringbuffer_data_t;

typedef struct {
  char *buf;
  volatile size_t write_ptr;
  volatile size_t read_ptr;
  size_t	size;
  size_t	size_mask;
  int	mlocked;
}
mfx_ringbuffer_t;

mfx_ringbuffer_t *mfx_ringbuffer_create(size_t sz);
void mfx_ringbuffer_free(mfx_ringbuffer_t *rb);
void mfx_ringbuffer_get_read_vector(const mfx_ringbuffer_t *rb,
                                       mfx_ringbuffer_data_t *vec);
void mfx_ringbuffer_get_write_vector(const mfx_ringbuffer_t *rb,
                                        mfx_ringbuffer_data_t *vec);
size_t mfx_ringbuffer_read(mfx_ringbuffer_t *rb, char *dest, size_t cnt);
size_t mfx_ringbuffer_peek(mfx_ringbuffer_t *rb, char *dest, size_t cnt);
void mfx_ringbuffer_read_advance(mfx_ringbuffer_t *rb, size_t cnt);
size_t mfx_ringbuffer_read_space(const mfx_ringbuffer_t *rb);
int mfx_ringbuffer_mlock(mfx_ringbuffer_t *rb);
void mfx_ringbuffer_reset(mfx_ringbuffer_t *rb);
void mfx_ringbuffer_reset_size (mfx_ringbuffer_t * rb, size_t sz);
size_t mfx_ringbuffer_write(mfx_ringbuffer_t *rb, const char *src,
                               size_t cnt);
void mfx_ringbuffer_write_advance(mfx_ringbuffer_t *rb, size_t cnt);
size_t mfx_ringbuffer_write_space(const mfx_ringbuffer_t *rb);
void lua_setRingbuffer(lua_DspFaust* dsp, mfx_ringbuffer_t* rb);
int openDspDialog(char* path);
]]


function sleep(sec)
    socket.select(nil, nil, sec)
end

FileWatcher = {}
setmetatable(FileWatcher, {
  __call = function(self, path)
  local last_mtime = sys_stat.lstat(path)
  if last_mtime ~= nil then last_mtime = last_mtime.st_mtime end
  return setmetatable({
    last_mtime = last_mtime,
    last_update = os.time(),
    path = path,
  }, {__index = FileWatcher})
  end
})

function FileWatcher.get_path(self)
  return self.path
end

function FileWatcher.update(self)
  local now = os.time()
  if now - self.last_update > 0.5 then
    self.last_mtime = sys_stat.lstat(self.path).st_mtime
    self.last_update = now
  end
end

function FileWatcher.get_last_mtime_mtime(self)
  self:update()
  return self.last_mtime
end

function FileWatcher.get_last_mtime_mtime_date(self)
  self:update()
  return os.date("%x %X", self.last_mtime)
end

function FileWatcher.has_changed(self)
  local prev = self.last_mtime
  self:update()
  return self.last_mtime ~= prev
end

return {
  sleep = sleep,
  FileWatcher = FileWatcher
}