//+------------------------------------------------------------------+
//|                                              EasyMQL Config      |
//|                                    Copyright 2026, EvolveBeyond  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, EvolveBeyond"
#property link      "https://www.mql5.com"
#property version   "1.00"

// Forward declarations
class EasyConfig;
class EasyEventManager;



#include <EasyCore.mqh>
#include <EasyHelpers.mqh>

//+------------------------------------------------------------------+
//| Configuration Parameter Class                                    |
//+------------------------------------------------------------------+
class ConfigParam
{
private:
   string              m_name;              // Parameter name
   string              m_description;       // Parameter description
   double              m_double_value;      // Double value
   int                 m_int_value;         // Integer value
   string              m_string_value;      // String value
   bool                m_bool_value;        // Boolean value
   uchar               m_type;              // Parameter type

public:
                     ConfigParam(void);
                     ConfigParam(string name, double value, string desc = "");
                     ConfigParam(string name, int value, string desc = "");
                     ConfigParam(string name, string value, string desc = "");
                     ConfigParam(string name, bool value, string desc = "");
                     ~ConfigParam(void);
   
   void               SetDouble(double value);
   void               SetInt(int value);
   void               SetString(string value);
   void               SetBool(bool value);
   
   double             GetDouble(void) const { return m_double_value; }
   int                GetInt(void) const { return m_int_value; }
   string             GetString(void) const { return m_string_value; }
   bool               GetBool(void) const { return m_bool_value; }
   string             GetName(void) const { return m_name; }
   string             GetDescription(void) const { return m_description; }
   uchar              GetType(void) const { return m_type; }
   
   // Parameter type constants
   static const uchar TYPE_DOUBLE = 1;
   static const uchar TYPE_INT = 2;
   static const uchar TYPE_STRING = 3;
   static const uchar TYPE_BOOL = 4;
};

//+------------------------------------------------------------------+
//| Constructor (default)                                            |
//+------------------------------------------------------------------+
ConfigParam::ConfigParam(void)
{
   m_name = "";
   m_description = "";
   m_double_value = 0.0;
   m_int_value = 0;
   m_string_value = "";
   m_bool_value = false;
   m_type = 0;
}

//+------------------------------------------------------------------+
//| Constructor (double)                                             |
//+------------------------------------------------------------------+
ConfigParam::ConfigParam(string name, double value, string desc)
{
   m_name = name;
   m_description = desc;
   m_double_value = value;
   m_int_value = 0;
   m_string_value = "";
   m_bool_value = false;
   m_type = TYPE_DOUBLE;
}

//+------------------------------------------------------------------+
//| Constructor (int)                                                |
//+------------------------------------------------------------------+
ConfigParam::ConfigParam(string name, int value, string desc)
{
   m_name = name;
   m_description = desc;
   m_double_value = 0.0;
   m_int_value = value;
   m_string_value = "";
   m_bool_value = false;
   m_type = TYPE_INT;
}

//+------------------------------------------------------------------+
//| Constructor (string)                                             |
//+------------------------------------------------------------------+
ConfigParam::ConfigParam(string name, string value, string desc)
{
   m_name = name;
   m_description = desc;
   m_double_value = 0.0;
   m_int_value = 0;
   m_string_value = value;
   m_bool_value = false;
   m_type = TYPE_STRING;
}

//+------------------------------------------------------------------+
//| Constructor (bool)                                               |
//+------------------------------------------------------------------+
ConfigParam::ConfigParam(string name, bool value, string desc)
{
   m_name = name;
   m_description = desc;
   m_double_value = 0.0;
   m_int_value = 0;
   m_string_value = "";
   m_bool_value = value;
   m_type = TYPE_BOOL;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
ConfigParam::~ConfigParam(void)
{
}

//+------------------------------------------------------------------+
//| Set double value                                                 |
//+------------------------------------------------------------------+
void ConfigParam::SetDouble(double value)
{
   m_double_value = value;
   m_type = TYPE_DOUBLE;
}

//+------------------------------------------------------------------+
//| Set int value                                                    |
//+------------------------------------------------------------------+
void ConfigParam::SetInt(int value)
{
   m_int_value = value;
   m_type = TYPE_INT;
}

//+------------------------------------------------------------------+
//| Set string value                                                 |
//+------------------------------------------------------------------+
void ConfigParam::SetString(string value)
{
   m_string_value = value;
   m_type = TYPE_STRING;
}

//+------------------------------------------------------------------+
//| Set bool value                                                   |
//+------------------------------------------------------------------+
void ConfigParam::SetBool(bool value)
{
   m_bool_value = value;
   m_type = TYPE_BOOL;
}

//+------------------------------------------------------------------+
//| Typed Configuration Parameter Class with Validation             |
//+------------------------------------------------------------------+
class TypedConfigParam : public ConfigParam
{
private:
   bool                m_required;          // Is this parameter required?
   double              m_min_value;         // Minimum value for validation
   double              m_max_value;         // Maximum value for validation
   string              m_validation_error;  // Last validation error

public:
                     TypedConfigParam(void);
                     TypedConfigParam(string name, double value, string desc = "", 
                                     bool required = false, double min_val = -DBL_MAX, double max_val = DBL_MAX);
                     TypedConfigParam(string name, int value, string desc = "", 
                                     bool required = false, int min_val = INT_MIN, int max_val = INT_MAX);
                     TypedConfigParam(string name, string value, string desc = "", bool required = false);
                     TypedConfigParam(string name, bool value, string desc = "", bool required = false);
                     ~TypedConfigParam(void);
   
   // Validation methods
   bool               validate(void);
   bool               isValid(void) const { return validate(); }
   string             getValidationError(void) const { return m_validation_error; }
   
   // Fluent setters for validation
   TypedConfigParam&  setRequired(bool required);
   TypedConfigParam&  setRange(double min_val, double max_val);
   TypedConfigParam&  setRange(int min_val, int max_val);
};

//+------------------------------------------------------------------+
//| Typed Configuration Parameter Implementation                     |
//+------------------------------------------------------------------+

// Constructors
TypedConfigParam::TypedConfigParam(void) : ConfigParam()
{
   m_required = false;
   m_min_value = -DBL_MAX;
   m_max_value = DBL_MAX;
   m_validation_error = "";
}

TypedConfigParam::TypedConfigParam(string name, double value, string desc, 
                                 bool required, double min_val, double max_val) : ConfigParam(name, value, desc)
{
   m_required = required;
   m_min_value = min_val;
   m_max_value = max_val;
   m_validation_error = "";
}

TypedConfigParam::TypedConfigParam(string name, int value, string desc, 
                                 bool required, int min_val, int max_val) : ConfigParam(name, (double)value, desc)
{
   m_required = required;
   m_min_value = (double)min_val;
   m_max_value = (double)max_val;
   m_validation_error = "";
}

TypedConfigParam::TypedConfigParam(string name, string value, string desc, bool required) : ConfigParam(name, value, desc)
{
   m_required = required;
   m_min_value = -DBL_MAX;
   m_max_value = DBL_MAX;
   m_validation_error = "";
}

TypedConfigParam::TypedConfigParam(string name, bool value, string desc, bool required) : ConfigParam(name, value, desc)
{
   m_required = required;
   m_min_value = -DBL_MAX;
   m_max_value = DBL_MAX;
   m_validation_error = "";
}

TypedConfigParam::~TypedConfigParam(void)
{
}

// Validation methods
bool TypedConfigParam::validate(void)
{
   if(m_type == TYPE_DOUBLE || m_type == TYPE_INT)
   {
      double val = (m_type == TYPE_DOUBLE) ? GetDouble() : (double)GetInt();
      if(val < m_min_value || val > m_max_value)
      {
         m_validation_error = "Value " + DoubleToString(val) + " out of range [" + 
                            DoubleToString(m_min_value) + ", " + DoubleToString(m_max_value) + "] for parameter '" + GetName() + "'";
         return false;
      }
   }
   
   if(m_required && m_type == TYPE_STRING && GetString() == "")
   {
      m_validation_error = "Required string parameter '" + GetName() + "' is empty";
      return false;
   }
   
   m_validation_error = "";
   return true;
}

// Fluent setters
TypedConfigParam& TypedConfigParam::setRequired(bool required)
{
   m_required = required;
   return *this;
}

TypedConfigParam& TypedConfigParam::setRange(double min_val, double max_val)
{
   m_min_value = min_val;
   m_max_value = max_val;
   return *this;
}

TypedConfigParam& TypedConfigParam::setRange(int min_val, int max_val)
{
   m_min_value = (double)min_val;
   m_max_value = (double)max_val;
   return *this;
}

//+------------------------------------------------------------------+
//| Typed Easy Configuration Class with Validation                   |
//+------------------------------------------------------------------+
class EasyConfig
{
private:
   TypedConfigParam    m_params[64];        // Configuration parameters with validation
   int                 m_param_count;       // Number of parameters
   string              m_config_name;       // Configuration name
   string              m_config_desc;       // Configuration description

public:
                     EasyConfig(void);
                     EasyConfig(string name, string desc = "");
                     ~EasyConfig(void);
   
   // Parameter management with validation
   EasyConfig&        addParam(string name, double value, string desc = "", 
                           bool required = false, double min_val = -DBL_MAX, double max_val = DBL_MAX);
   EasyConfig&        addParamInt(string name, int value, string desc = "", 
                             bool required = false, int min_val = INT_MIN, int max_val = INT_MAX);
   EasyConfig&        addParamString(string name, string value, string desc = "", bool required = false);
   EasyConfig&        addParamBool(string name, bool value, string desc = "", bool required = false);
   
   // Parameter retrieval
   double             getDouble(string name, double default_val = 0.0);
   int                getInt(string name, int default_val = 0);
   string             getString(string name, string default_val = "");
   bool               getBool(string name, bool default_val = false);
   
   // Parameter update
   bool               setDouble(string name, double value);
   bool               setInt(string name, int value);
   bool               setString(string name, string value);
   bool               setBool(string name, bool value);
   
   // Configuration info
   string             getName(void) const { return m_config_name; }
   string             getDescription(void) const { return m_config_desc; }
   int                getParamCount(void) const { return m_param_count; }
   
   // Validation
   bool               validate(void);      // Validate all parameters
   bool               validateParam(string name); // Validate specific parameter
   void               logValidationErrors(void); // Log all validation errors
   bool               loadFromFile(string filename);
   bool               saveToFile(string filename);
};

//+------------------------------------------------------------------+
//| Constructor (default)                                            |
//+------------------------------------------------------------------+
EasyConfig::EasyConfig(void)
{
   m_config_name = "DefaultConfig";
   m_config_desc = "Default configuration";
   m_param_count = 0;
}

//+------------------------------------------------------------------+
//| Constructor (with name)                                          |
//+------------------------------------------------------------------+
EasyConfig::EasyConfig(string name, string desc)
{
   m_config_name = name;
   m_config_desc = (desc == "") ? name + " configuration" : desc;
   m_param_count = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
EasyConfig::~EasyConfig(void)
{
}

//+------------------------------------------------------------------+
//| Add double parameter with validation                             |
//+------------------------------------------------------------------+
EasyConfig& EasyConfig::addParam(string name, double value, string desc, bool required, double min_val, double max_val)
{
   if(m_param_count >= 64)
      return *this;
      
   m_params[m_param_count] = TypedConfigParam(name, value, desc, required, min_val, max_val);
   m_param_count++;
   return *this;
}

//+------------------------------------------------------------------+
//| Add integer parameter with validation                            |
//+------------------------------------------------------------------+
EasyConfig& EasyConfig::addParamInt(string name, int value, string desc, bool required, int min_val, int max_val)
{
   if(m_param_count >= 64)
      return *this;
      
   m_params[m_param_count] = TypedConfigParam(name, value, desc, required, min_val, max_val);
   m_param_count++;
   return *this;
}

//+------------------------------------------------------------------+
//| Add string parameter                                             |
//+------------------------------------------------------------------+
EasyConfig& EasyConfig::addParamString(string name, string value, string desc, bool required)
{
   if(m_param_count >= 64)
      return *this;
      
   m_params[m_param_count] = TypedConfigParam(name, value, desc, required);
   m_param_count++;
   return *this;
}

//+------------------------------------------------------------------+
//| Add boolean parameter                                            |
//+------------------------------------------------------------------+
EasyConfig& EasyConfig::addParamBool(string name, bool value, string desc, bool required)
{
   if(m_param_count >= 64)
      return *this;
      
   m_params[m_param_count] = TypedConfigParam(name, value, desc, required);
   m_param_count++;
   return *this;
}

//+------------------------------------------------------------------+
//| Get double parameter                                             |
//+------------------------------------------------------------------+
double EasyConfig::getDouble(string name, double default_val)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && (m_params[i].GetType() == ConfigParam::TYPE_DOUBLE || 
                                        m_params[i].GetType() == ConfigParam::TYPE_INT))
      {
         return m_params[i].GetDouble();
      }
   }
   return default_val;
}

//+------------------------------------------------------------------+
//| Get integer parameter                                            |
//+------------------------------------------------------------------+
int EasyConfig::getInt(string name, int default_val)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && m_params[i].GetType() == ConfigParam::TYPE_INT)
      {
         return m_params[i].GetInt();
      }
   }
   return default_val;
}

//+------------------------------------------------------------------+
//| Get string parameter                                             |
//+------------------------------------------------------------------+
string EasyConfig::getString(string name, string default_val)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && m_params[i].GetType() == ConfigParam::TYPE_STRING)
      {
         return m_params[i].GetString();
      }
   }
   return default_val;
}

//+------------------------------------------------------------------+
//| Get boolean parameter                                            |
//+------------------------------------------------------------------+
bool EasyConfig::getBool(string name, bool default_val)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && m_params[i].GetType() == ConfigParam::TYPE_BOOL)
      {
         return m_params[i].GetBool();
      }
   }
   return default_val;
}

//+------------------------------------------------------------------+
//| Set double parameter                                             |
//+------------------------------------------------------------------+
bool EasyConfig::setDouble(string name, double value)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && (m_params[i].GetType() == ConfigParam::TYPE_DOUBLE || 
                                        m_params[i].GetType() == ConfigParam::TYPE_INT))
      {
         m_params[i].SetDouble(value);
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Set integer parameter                                            |
//+------------------------------------------------------------------+
bool EasyConfig::setInt(string name, int value)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && m_params[i].GetType() == ConfigParam::TYPE_INT)
      {
         m_params[i].SetInt(value);
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Set string parameter                                             |
//+------------------------------------------------------------------+
bool EasyConfig::setString(string name, string value)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && m_params[i].GetType() == ConfigParam::TYPE_STRING)
      {
         m_params[i].SetString(value);
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Set boolean parameter                                            |
//+------------------------------------------------------------------+
bool EasyConfig::setBool(string name, bool value)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name && m_params[i].GetType() == ConfigParam::TYPE_BOOL)
      {
         m_params[i].SetBool(value);
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Validate configuration                                           |
//+------------------------------------------------------------------+
bool EasyConfig::validate(void)
{
   bool all_valid = true;
   for(int i = 0; i < m_param_count; i++)
   {
      if(!m_params[i].validate())
      {
         EasyHelpers::logWarning("Config validation failed: " + m_params[i].getValidationError());
         all_valid = false;
      }
   }
   return all_valid;
}

bool EasyConfig::validateParam(string name)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(m_params[i].GetName() == name)
      {
         bool is_valid = m_params[i].validate();
         if(!is_valid)
         {
            EasyHelpers::logWarning("Config validation failed: " + m_params[i].getValidationError());
         }
         return is_valid;
      }
   }
   return false; // Parameter not found
}

void EasyConfig::logValidationErrors(void)
{
   for(int i = 0; i < m_param_count; i++)
   {
      if(!m_params[i].validate())
      {
         EasyHelpers::logWarning("Config validation error: " + m_params[i].getValidationError());
      }
   }
}

//+------------------------------------------------------------------+
//| Load configuration from file                                     |
//+------------------------------------------------------------------+
bool EasyConfig::loadFromFile(string filename)
{
   // Implementation for loading from file
   // This is a simplified version - in a real implementation you would read from a file
   EasyHelpers::log("Loading configuration from: " + filename);
   return true;
}

//+------------------------------------------------------------------+
//| Save configuration to file                                       |
//+------------------------------------------------------------------+
bool EasyConfig::saveToFile(string filename)
{
   // Implementation for saving to file
   // This is a simplified version - in a real implementation you would write to a file
   EasyHelpers::log("Saving configuration to: " + filename);
   return true;
}

//+------------------------------------------------------------------+
//| Event Manager Class                                              |
//+------------------------------------------------------------------+
class EasyEventManager
{
private:
   string              m_events[32];        // Event names
   bool                m_event_states[32];  // Event states
   int                 m_event_count;       // Number of events
   bool                m_initialized;       // Initialization flag

public:
                     EasyEventManager(void);
                     ~EasyEventManager(void);
   
   bool               Initialize(void);
   void               Deinitialize(void);
   
   // Event management
   bool               addEvent(string event_name);
   bool               triggerEvent(string event_name);
   bool               isEventTriggered(string event_name);
   bool               resetEvent(string event_name);
   void               resetAllEvents(void);
   
   // Event handling
   bool               onEvent(string event_name, void(*handler)(void));
   
   // Status
   bool               IsInitialized(void) const { return m_initialized; }
   int                getEventCount(void) const { return m_event_count; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
EasyEventManager::EasyEventManager(void)
{
   m_event_count = 0;
   m_initialized = false;
   
   for(int i = 0; i < 32; i++)
   {
      m_events[i] = "";
      m_event_states[i] = false;
   }
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
EasyEventManager::~EasyEventManager(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize                                                       |
//+------------------------------------------------------------------+
bool EasyEventManager::Initialize(void)
{
   m_initialized = true;
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                     |
//+------------------------------------------------------------------+
void EasyEventManager::Deinitialize(void)
{
   resetAllEvents();
   m_initialized = false;
}

//+------------------------------------------------------------------+
//| Add event                                                        |
//+------------------------------------------------------------------+
bool EasyEventManager::addEvent(string event_name)
{
   if(m_event_count >= 32)
      return false;
   
   // Check if event already exists
   for(int i = 0; i < m_event_count; i++)
   {
      if(m_events[i] == event_name)
         return true; // Event already exists
   }
   
   m_events[m_event_count] = event_name;
   m_event_states[m_event_count] = false;
   m_event_count++;
   
   return true;
}

//+------------------------------------------------------------------+
//| Trigger event                                                    |
//+------------------------------------------------------------------+
bool EasyEventManager::triggerEvent(string event_name)
{
   for(int i = 0; i < m_event_count; i++)
   {
      if(m_events[i] == event_name)
      {
         m_event_states[i] = true;
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Check if event is triggered                                      |
//+------------------------------------------------------------------+
bool EasyEventManager::isEventTriggered(string event_name)
{
   for(int i = 0; i < m_event_count; i++)
   {
      if(m_events[i] == event_name)
      {
         return m_event_states[i];
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Reset event                                                      |
//+------------------------------------------------------------------+
bool EasyEventManager::resetEvent(string event_name)
{
   for(int i = 0; i < m_event_count; i++)
   {
      if(m_events[i] == event_name)
      {
         m_event_states[i] = false;
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Reset all events                                                 |
//+------------------------------------------------------------------+
void EasyEventManager::resetAllEvents(void)
{
   for(int i = 0; i < m_event_count; i++)
   {
      m_event_states[i] = false;
   }
}

//+------------------------------------------------------------------+
//| Event handler (simplified)                                       |
//+------------------------------------------------------------------+
bool EasyEventManager::onEvent(string event_name, void(*handler)(void))
{
   if(isEventTriggered(event_name))
   {
      if(handler != NULL)
         handler();
      resetEvent(event_name);
      return true;
   }
   return false;
}

// Global configuration instance
EasyConfig g_config("GlobalConfig", "Global EasyMQL Configuration");
EasyEventManager g_event_manager;