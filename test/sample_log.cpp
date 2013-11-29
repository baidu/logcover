XXX_LOG_WARNING("fail to find, index is not loaded. [table='%s' index='%s']", \
        m_table->table_name().c_str(), \
        m_table->index_name().c_str()); \
    return 0;
BS_LOG_WARNING(TASK_FILE_LOG_FMT("error read from file, error [%m], "
            "need_read_len[%lu], "
            "read_len [%lu], _read_buf_len[%lu], ")
        "file->offset [%llu], file->length [%llu]",
        TASK_FILE_LOG_ARGS(file, need_read_len, read_len, _read_buf_len,
            file->offset, file->length));
XXX_WRITE_LOG(UL_LOG_WARNING, "fail to open file "
        "[filename:%s] [tname:%s] [begin_pos:%lu]",
        file_name, tname, begin_pos);
XXX_WRITE_LOG(UL_LOG_WARNING,
        "open config file failed [path:%s] [file:%s] [ret:%d]",
        db_path,
        this->_db_info_file,
        ret);
XXX_WRITE_LOG(UL_LOG_WARNING, "fail to open file "
        "[filename:%s]", file_name.c_str());
ML_LOG_WARNING(
        "write data_path_in_use state [%s] to %s error!",
        temp, g_conf.data_path_state_record_path );
#define CHECK_ROWCURSOR_INIT() \
    if (!m_is_inited) {\
        OLAP_LOG_FATAL("RowCurosr is not inited.");\
        return OLAP_ERR_NOT_INITED;\
    }
XXX_LOG_WARNING("fail to find, index is not loaded. [table='%s' index='%s']", \
        m_table->table_name().c_str(), \
        m_table->index_name().c_str()); \

//olap bug
#define xxx_LOG_FATAL_SOCK(fmt, arg...) \
    OLAP_LOG_WRITE(UL_LOG_FATAL, "[logid:%s][reqip:%s]"fmt, \
            ub_log_getbasic(UB_LOG_LOGID), ub_log_getbasic(UB_LOG_REQIP), ##arg)

this is a test);

xxx_LOG_WARNING(TASK_FILE_LOG_FMT("error read from file, error [%m],\ 
            need_read_len[%lu], "
            "read_len [%lu], _read_buf_len[%lu], ")
        "file->offset [%llu], file->length [%llu]",
        TASK_FILE_LOG_ARGS(file, need_read_len, read_len, _read_buf_len,
            file->offset, file->length));

//matrix bug
enum{
WARNING,
    TIMEOUT,
    };  
static const std::string to_string(const type t) {
    switch (t) {
        case RUNNING : return "RUNNING";
        case STARTING: return "STARTING";
        case ERROR   : return "ERROR";
        case TIMEOUT : return "TIMEOUT";
        default     : throw std::runtime_error("Invalid HealthCheckStatus");
